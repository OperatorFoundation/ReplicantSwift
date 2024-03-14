//
//  Omnitone.swift
//
//

import Foundation

import Chord
import Datable
import Ghostwriter
import TransmissionAsync

public enum OmnitoneMode: String, Codable
{
    case POP3Client
    case POP3Server
    
}

public class Omnitone: ToneBurstAsync, Codable
{
    public var type: ReplicantSwift.ToneBurstType = .starburst
    
    let mode: OmnitoneMode

    public init(_ mode: OmnitoneMode)
    {
        self.mode = mode
    }

    public func perform(connection: TransmissionAsync.AsyncConnection) async throws
    {
        let instance = OmnitoneInstance(self.mode, connection)
        try await instance.perform()
    }
}

public struct OmnitoneInstance
{
    let connection: TransmissionAsync.AsyncConnection
    let mode: OmnitoneMode

    public init(_ mode: OmnitoneMode, _ connection: TransmissionAsync.AsyncConnection)
    {
        self.mode = mode
        self.connection = connection
    }

    public func perform() async throws
    {
        switch mode
        {
            
            case .POP3Client:
                try await handlePOP3Client()
            
            case .POP3Server:
                try await handlePOP3Server()
            
        }
    }
    
    func listen(structuredText: StructuredText, maxSize: Int = 255, timeout: Duration = .seconds(60)) async throws -> MatchResult
    {
        let listenTask: Task<MatchResult, Error> = Task
        {
            var buffer = Data()
            while buffer.count < maxSize
            {
                let byte = try await connection.readSize(1)

                buffer.append(byte)

                guard let string = String(data: buffer, encoding: .utf8) else
                {
                    // This could fail because we're in the middle of a UTF8 rune.
                    continue
                }

                let result = structuredText.match(string: string)
                switch result
                {
                    case .FAILURE:
                        return result

                    case .SHORT:
                        continue

                    case .SUCCESS(_):
                        return result
                }
            }

            throw StarburstError.maxSizeReached
        }
        
        Task
        {
            try await Task.sleep(for: timeout)
            listenTask.cancel()
        }
        
        return try await listenTask.value
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

    private func handlePOP3Server() async throws
    {
        try await self.speak(structuredText: StructuredText(TypedText.text("+OK POP3 server ready."), TypedText.newline(Newline.crlf)))
        let _ = try await self.listen(structuredText: StructuredText(TypedText.text("STLS"), TypedText.newline(Newline.crlf)), timeout: Duration.seconds(5))
        try await self.speak(structuredText: StructuredText(TypedText.text("+OK Begin TLS Negotiation"), TypedText.newline(Newline.crlf)))
    }

    private func handlePOP3Client() async throws
    {
        let _ = try await self.listen(structuredText: StructuredText(TypedText.text("+OK POP3 server ready."), TypedText.newline(Newline.crlf)), timeout: Duration.seconds(5))
        try await self.speak(structuredText: StructuredText(TypedText.text("STLS"), TypedText.newline(Newline.crlf)))
        let _ = try await self.listen(structuredText: StructuredText(TypedText.text("+OK Begin TLS Negotiation"), TypedText.newline(Newline.crlf)), timeout: Duration.seconds(5))
    }
}

public enum OmnitoneError: Error
{
    case timeout
    case connectionClosed
    case writeFailed
    case readFailed
    case listenFailed
    case speakFailed
    case maxSizeReached
}
