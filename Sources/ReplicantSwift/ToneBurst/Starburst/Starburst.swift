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
        guard let firstClientListen = ListenTemplate(Template("220 $1 SMTP service ready\r\n"), patterns: [ExtractionPattern("^([a-zA-Z0-9.-]+)", .string)], maxSize: 253, maxTimeoutSeconds: Int.max) else {
            throw StarburstError.listenFailed
        }
        
        try listen(template: firstClientListen)

        try speak(template: Template("EHLO $1\r\n"), details: [Detail.string("mail.imc.org")])

        guard let secondClientListen = ListenTemplate(Template("$1\r\n"), patterns: [ExtractionPattern("250 (STARTTLS)", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
            throw StarburstError.listenFailed
        }
        
        try listen(template: secondClientListen)

        try speak(string: "STARTTLS\r\n")

        guard let thirdClientListen = ListenTemplate(Template("$1\r\n"), patterns: [ExtractionPattern("^(.+)\r\n", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
            throw StarburstError.listenFailed
        }
        
        try listen(template: thirdClientListen)
    }

    func handleSMTPServer() throws
    {
        try speak(template: Template("220 $1 SMTP service ready\r\n"), details: [Detail.string("mail.imc.org")])
        
        guard let firstServerListen = ListenTemplate(Template("EHLO $1\r\n"), patterns: [ExtractionPattern("^([a-zA-Z0-9.-]+)\r", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
            throw StarburstError.listenFailed
        }
        
        try listen(template: firstServerListen)

        try speak(template: Template("250-$1 offers a warm hug of welcome\r\n250-$2\r\n250-$3\r\n250 $4\r\n"), details: [Detail.string("mail.imc.org"), Detail.string("8BITMIME"), Detail.string("DSN"), Detail.string("STARTTLS")])

        // FIXME: not sure about this size
        let listenString: String = try listen(size: "STARTTLS\r\n".count + 1) // \r\n is counted as one on .count

        try speak(template: Template("220 $1\r\n"), details: [Detail.string("Go ahead")])
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
        var running = true
        
        queue.async
        {
            var buffer = Data()
            while buffer.count < template.maxSize && running
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
                    continue
                }
            }
            
            resultQueue.enqueue(element: nil)
            lock.signal()
            return
        }

        // .now() + DispatchTimeoutInterval.seconds(maxtimeoutinseconds)
        let waitResult = lock.wait(timeout: DispatchTime.distantFuture)
        switch waitResult
        {
            case .success:
                guard let details = resultQueue.dequeue() else
                {
                    throw StarburstError.readFailed
                }

                return details

            case .timedOut:
                running = false
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
    case listenFailed
    case speakFailed
    case maxSizeReached
}
