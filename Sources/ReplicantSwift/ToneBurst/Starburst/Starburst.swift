//
//  Starburst.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/9/22.
//

import Foundation

import Chord
import Datable
import Ghostwriter
import Transmission

public class Starburst: ToneBurst
{
    let config: StarburstConfig

    public init(_ config: StarburstConfig)
    {
        self.config = config
    }

    public func perform(connection: Transmission.Connection) throws
    {
        let instance = StarburstInstance(self.config, connection)
        try instance.perform()
    }
}

public struct StarburstInstance
{
    let config: StarburstConfig
    let connection: Transmission.Connection

    public init(_ config: StarburstConfig, _ connection: Transmission.Connection)
    {
        self.config = config
        self.connection = connection
    }

    public func perform() throws
    {
        switch config
        {
            case .SMTPClient:
                try handleSMTPClient()

            case .SMTPServer:
                try handleSMTPServer()
        }
    }

    func handleSMTPClient() throws
    {
        // FIXME
    }

    func handleSMTPServer() throws
    {
        // FIXME
    }

    func speak(data: Data) throws
    {
        guard connection.write(data: data) else
        {
            throw StarburstError.writeFailed
        }
    }

    func speak(string: String) throws
    {
        guard connection.write(string: string) else
        {
            throw StarburstError.writeFailed
        }
    }

    func speak(template: Template, details: [Detail]) throws
    {
        do
        {
            let string = try Ghostwriter.generate(template, details)
            guard connection.write(string: string) else
            {
                throw StarburstError.writeFailed
            }
        }
        catch
        {
            print(error)
            throw StarburstError.writeFailed
        }
    }

    func listen(size: Int) throws -> Data
    {
        guard let data = connection.read(size: size) else
        {
            throw StarburstError.readFailed
        }

        return data
    }

    func listen(size: Int) throws -> String
    {
        guard let data = connection.read(size: size) else
        {
            throw StarburstError.readFailed
        }

        return data.string
    }

    func listen(template: ListenTemplate) throws -> [Detail]
    {
        let lock = DispatchSemaphore(value: 0)
        let resultQueue = BlockingQueue<[Detail]?>()
        let queue = DispatchQueue(label: "Starburst.listen")

        queue.async
        {
            var buffer = Data()
            while true
            {
                guard let byte = connection.read(size: 1) else
                {
                    resultQueue.enqueue(element: nil)
                    lock.signal()
                    return
                }

                buffer.append(byte)

                guard let string = String(data: buffer, encoding: .utf8) else
                {
                    // This could fail because we're in the middle of a UTF8 rune.
                    continue
                }

                do
                {
                    let details = try Ghostwriter.parse(template.template, template.patterns, string)
                    resultQueue.enqueue(element: details)
                    lock.signal()
                    return
                }
                catch
                {
                    print(error)
                    resultQueue.enqueue(element: nil)
                    lock.signal()
                    return
                }
            }
        }

        let waitResult = lock.wait(timeout: .now() + template.maxTimeoutSeconds)
        switch waitResult
        {
            case .success:
                guard let details = resultQueue.dequeue() else
                {
                    throw StarburstError.readFailed
                }

                return details

            case .timedOut:
                throw StarburstError.timeout
        }
    }

    func wait(seconds: Double)
    {
        let lock = DispatchSemaphore(value: 0)
        _ = lock.wait(timeout: .now() + seconds)
    }
}

public enum StarburstError: Error
{
    case timeout
    case connectionClosed
    case writeFailed
    case readFailed
}
