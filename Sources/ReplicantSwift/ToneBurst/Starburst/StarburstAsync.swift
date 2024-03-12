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
import TransmissionAsync

open class StarburstAsync: ToneBurstAsync, Codable
{
    public var type: ToneBurstType = .starburst
    
    let mode: StarburstMode

    public init(_ mode: StarburstMode)
    {
        self.mode = mode
    }

    open func perform(connection: TransmissionAsync.AsyncConnection) async throws
    {
        let instance = StarburstInstanceAsync(self.mode, connection)
        try await instance.perform()
    }
}

public struct StarburstInstanceAsync
{
    let connection: TransmissionAsync.AsyncConnection
    let mode: StarburstMode

    public init(_ mode: StarburstMode, _ connection: TransmissionAsync.AsyncConnection)
    {
        self.mode = mode
        self.connection = connection
    }

    public func perform() async throws
    {
        switch mode
        {
            case .SMTPClient:
            try await handleSMTPClient()

            case .SMTPServer:
            try await handleSMTPServer()
        }
    }

    func handleSMTPClient() async throws
    {
        guard let firstClientListen = ListenTemplate(Template("220 $1 SMTP service ready\r\n"), patterns: [ExtractionPattern("^([a-zA-Z0-9.-]+)", .string)], maxSize: 253, maxTimeoutSeconds: Int.max) else {
            throw StarburstError.listenFailed
        }
        
        let _ = try await listen(template: firstClientListen)

        try await speak(template: Template("EHLO $1\r\n"), details: [Detail.string("mail.imc.org")])

        guard let secondClientListen = ListenTemplate(Template("$1\r\n"), patterns: [ExtractionPattern("250 (STARTTLS)", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
            throw StarburstError.listenFailed
        }
        
        _ = try await listen(template: secondClientListen)

        try await speak(string: "STARTTLS\r\n")

        guard let thirdClientListen = ListenTemplate(Template("$1\r\n"), patterns: [ExtractionPattern("^(.+)\r\n", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
            throw StarburstError.listenFailed
        }
        
        _ = try await listen(template: thirdClientListen)
    }

    func handleSMTPServer() async throws
    {
        try await speak(template: Template("220 $1 SMTP service ready\r\n"), details: [Detail.string("mail.imc.org")])
        
        guard let firstServerListen = ListenTemplate(Template("EHLO $1\r\n"), patterns: [ExtractionPattern("^([a-zA-Z0-9.-]+)\r", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
            throw StarburstError.listenFailed
        }
        
        _ = try await listen(template: firstServerListen)

        // % 5 is mod, which divides by five, discards the result, then returns the remainder
        let hour = Calendar.current.component(.hour, from: Date()) % 5
        let welcome: String
        switch hour
        {
            // These are all real SMTP welcome messages found in online examples of SMTP conversations.
            case 0:
                welcome = "offers a warm hug of welcome"
            case 1:
                welcome = "is my domain name."
            case 2:
                welcome = "I am glad to meet you"
            case 3:
                welcome = "says hello"
            case 4:
                welcome = "Hello"

            default:
                welcome = ""
        }

        try await speak(template: Template("250-$1 $2\r\n250-$3\r\n250-$4\r\n250 $5\r\n"), details: [Detail.string("mail.imc.org"), Detail.string(welcome), Detail.string("8BITMIME"), Detail.string("DSN"), Detail.string("STARTTLS")])

        // FIXME: not sure about this size
        let _: String = try await listen(size: "STARTTLS\r\n".count + 1) // \r\n is counted as one on .count

        try await speak(template: Template("220 $1\r\n"), details: [Detail.string("Go ahead")])
    }

    func speak(data: Data) async throws
    {
        try await connection.write(data)
    }

    func speak(string: String) async throws
    {
        try await connection.writeString(string: string)
    }

    func speak(template: Template, details: [Detail]) async throws
    {
        do
        {
            let string = try Ghostwriter.generate(template, details)
            try await connection.writeString(string: string)
        }
        catch
        {
            print(error)
            throw StarburstError.writeFailed
        }
    }
    
    func speak(structuredText: StructuredText) async throws
    {
        do
        {
            let string = structuredText.string
            try await connection.writeString(string: string)
        }
        catch
        {
            print(error)
            throw StarburstError.writeFailed
        }
    }

    func listen(size: Int) async throws -> Data
    {
        return try await connection.readSize(size)
    }

    func listen(size: Int) async throws -> String
    {
        let data = try await connection.readSize(size)
        return data.string
    }

    func listen(template: ListenTemplate) async throws -> [Detail]
    {
        let listenTask: Task<[Detail]?, Error> = Task {
            var buffer = Data()
            while buffer.count < template.maxSize
            {
                do {
                    let byte = try await connection.readSize(1)
                    
                    buffer.append(byte)
                    
                    guard let string = String(data: buffer, encoding: .utf8) else
                    {
                        // This could fail because we're in the middle of a UTF8 rune.
                        continue
                    }
                    
                    do
                    {
                        return try Ghostwriter.parse(template.template, template.patterns, string)
                    }
                    catch
                    {
                        continue
                    }
                } catch {
                    return nil
                }
            }
            
            return nil
        }
        
        let _ = Task {
            try await Task.sleep(for: .seconds(60))
            listenTask.cancel()
        }
        
        do {
            guard let result = try await listenTask.value else {
                throw StarburstError.readFailed
            }
            return result
        } catch {
            throw StarburstError.timeout
        }
    }
    
    func listen(structuredText: StructuredText, maxSize: Int = 255, timeout: Duration = .seconds(60)) async throws -> String
    {
        let listenTask: Task<MatchResult?, Error> = Task
        {
            var buffer = Data()
            while buffer.count < maxSize
            {
                do
                {
                    let byte = try await connection.readSize(1)
                    
                    buffer.append(byte)
                    
                    guard let string = String(data: buffer, encoding: .utf8) else
                    {
                        // This could fail because we're in the middle of a UTF8 rune that is encoded as multiple bytes.
                        continue
                    }
                    
                    do
                    {
                        let matchResult = try structuredText.match(string: string)

                        switch matchResult
                        {
                            case .SUCCESS(let value):
                                return value

                            case .SHORT:
                                continue

                            case .FAILURE:
                                throw StarburstError.listenFailed
                        }
                    }
                    catch
                    {
                        continue
                    }
                }
                catch
                {
                    return nil
                }
            }
            
            return nil
        }
        
        let _ = Task
        {
            try await Task.sleep(for: timeout)
            listenTask.cancel()
        }
        
        do
        {
            guard let result = try await listenTask.value else
            {
                throw StarburstError.readFailed
            }
            return result
        }
        catch
        {
            throw StarburstError.timeout
        }
    }

    func wait(seconds: Double)
    {
        let lock = DispatchSemaphore(value: 0)
        _ = lock.wait(timeout: .now() + seconds)
    }
}
