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

open class Starburst: ToneBurst
{
    let mode: StarburstMode

    public init(_ mode: StarburstMode)
    {
        self.mode = mode
        super.init()
    }
    
    required public init(from decoder: any Decoder) throws 
    {
        let container = try decoder.singleValueContainer()
        self.mode = try container.decode(StarburstMode.self)
        super.init()
    }
    
    open override func perform(connection: TransmissionAsync.AsyncConnection) async throws
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
    
    private func handleSMTPClient() async throws
    {
        let _ = try await self.listen(structuredText: StructuredText(TypedText.text("220 "), TypedText.regexp("^([a-zA-Z0-9.-]+)"), TypedText.text(" SMTP service ready"), TypedText.newline(Newline.crlf)), maxSize: 253, timeout: Duration.seconds(9223372036854775807))
        try await self.speak(structuredText: StructuredText(TypedText.text("EHLO mail.imc.org"), TypedText.newline(Newline.crlf)))
        let _ = try await self.listen(structuredText: StructuredText(TypedText.text("250 STARTTLS"), TypedText.newline(Newline.crlf)), maxSize: 253, timeout: Duration.seconds(10))
        try await self.speak(structuredText: StructuredText(TypedText.text("STARTTLS"), TypedText.newline(Newline.crlf)))
        let _ = try await self.listen(structuredText: StructuredText(TypedText.regexp("^(.+)$"), TypedText.newline(Newline.crlf)), maxSize: 253, timeout: Duration.seconds(10))
    }

    func handleSMTPServer() async throws
    {
//        try await speak(template: Template("220 $1 SMTP service ready\r\n"), details: [Detail.string("mail.imc.org")])
//        
//        guard let firstServerListen = ListenTemplate(Template("EHLO $1\r\n"), patterns: [ExtractionPattern("^([a-zA-Z0-9.-]+)\r", .string)], maxSize: 253, maxTimeoutSeconds: 10) else {
//            throw StarburstError.listenFailed
//        }
//        
//        _ = try await listen(template: firstServerListen)
//
//        // % 5 is mod, which divides by five, discards the result, then returns the remainder
//        let hour = Calendar.current.component(.hour, from: Date()) % 5
//        let welcome: String
//        switch hour
//        {
//            // These are all real SMTP welcome messages found in online examples of SMTP conversations.
//            case 0:
//                welcome = "offers a warm hug of welcome"
//            case 1:
//                welcome = "is my domain name."
//            case 2:
//                welcome = "I am glad to meet you"
//            case 3:
//                welcome = "says hello"
//            case 4:
//                welcome = "Hello"
//
//            default:
//                welcome = ""
//        }
//
//        try await speak(template: Template("250-$1 $2\r\n250-$3\r\n250-$4\r\n250 $5\r\n"), details: [Detail.string("mail.imc.org"), Detail.string(welcome), Detail.string("8BITMIME"), Detail.string("DSN"), Detail.string("STARTTLS")])
//
//        // FIXME: not sure about this size
//        let _: String = try await listen(size: "STARTTLS\r\n".count + 1) // \r\n is counted as one on .count
//
//        try await speak(template: Template("220 $1\r\n"), details: [Detail.string("Go ahead")])
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
                            case .SUCCESS(_):
                                return matchResult

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
            
            switch result
            {
                case .SUCCESS(let value):
                    return value

                default:
                    throw StarburstError.listenFailed
            }
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

public enum StarburstMode: String, Codable 
{
    case SMTPServer
    case SMTPClient
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
