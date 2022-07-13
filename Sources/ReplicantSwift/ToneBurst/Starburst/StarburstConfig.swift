//
//  StarburstConfig.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/9/22.
//

import Foundation

import Ghostwriter

public enum StarburstConfig: Codable
{
    case SMTPServer
    case SMTPClient
    
    public func construct() -> Starburst
    {
        return Starburst(self)
    }
}

public enum Speak: Codable, CustomStringConvertible
{
    public var description: String
    {
        switch self
        {
            case .bytes(let value):
                return "Speak.bytes(\(value))"

            case .text(let value):
                return "Speak.text(\(value))"

            case .template(let template, let details):
                return "Speak.bytes(\(template), \(details))"
        }
    }

    case bytes(Data)
    case text(String)
    case template(Template, [Detail])
}

public enum Listen: Codable
{
    case bytes(Int)
    case text(Int)
    case parse(ListenTemplate)
    case match(ListenTemplate)
}

public struct ListenTemplate: Codable
{
    let template: Template
    let patterns: [ExtractionPattern]
    let maxSize: Int
    let maxTimeoutSeconds: Int

    public init?(_ template: Template, patterns: [ExtractionPattern], maxSize: Int, maxTimeoutSeconds: Int)
    {
        guard maxSize > 0 else
        {
            return nil
        }

        guard maxTimeoutSeconds > 0 else
        {
            return nil
        }

        self.template = template
        self.patterns = patterns
        self.maxSize = maxSize
        self.maxTimeoutSeconds = maxTimeoutSeconds
    }
}

public struct Wait: Codable
{
    let interval: TimeInterval

    public init(_ interval: TimeInterval)
    {
        self.interval = interval
    }
}
