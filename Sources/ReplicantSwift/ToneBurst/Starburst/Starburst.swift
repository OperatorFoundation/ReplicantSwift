//
//  Starburst.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/9/22.
//

import Foundation

import Ghostwriter
import Transmission

public class Starburst: Codable, ToneBurst
{
    let config: StarburstConfig
    var listening = false

    public init(_ config: StarburstConfig)
    {
        self.config = config
    }

    public func perform(connection: Transmission.Connection, completion: @escaping (Error?) -> Void)
    {
        let queue = DispatchQueue(label: "Starburst")

        do
        {
            for moment in config.moments
            {
                switch moment
                {
                    case .speak(let speak):
                        let string = try Ghostwriter.generate(speak.template, speak.details)
                        guard connection.write(string: string) else
                        {
                            completion(StarburstError.connectionClosed)
                            return
                        }

                    case .listen(let listen):
                        self.listening = true

                        queue.asyncAfter(deadline: .now() + listen.maxTimeoutSeconds)
                        {
                            self.listening = false
                        }

                        var buffer = Data()
                        while self.listening
                        {
                            guard let byte = connection.read(size: 1) else
                            {
                                completion(StarburstError.connectionClosed)
                                return
                            }

                            buffer.append(byte)

                            guard let string = String(data: buffer, encoding: .utf8) else
                            {
                                // This could fail because we're in the middle of a UTF8 rune.
                                continue
                            }

                            let details = try Ghostwriter.parse(listen.template, listen.patterns, string)
                            for (detail, answer) in zip(details, listen.answers)
                            {
                                guard detail == answer else
                                {
                                    // This could fail because we don't have all the bytes yet.
                                    continue
                                }
                            }
                        }

                        completion(StarburstError.timeout)
                        return
                }
            }
        }
        catch
        {
            completion(error)
        }
    }
}

public enum StarburstError: Error
{
    case timeout
    case connectionClosed
}
