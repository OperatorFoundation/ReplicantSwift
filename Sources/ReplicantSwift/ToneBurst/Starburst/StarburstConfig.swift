//
//  StarburstConfig.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/9/22.
//

import Foundation

import Ghostwriter

public struct StarburstConfig: Codable
{
    let moments: [Moment]

    public init(_ moments: [Moment])
    {
        self.moments = moments
    }

    public func construct() -> Starburst
    {
        return Starburst(self)
    }
}

public enum Moment: Codable
{
    case speak(Speak)
    case listen(Listen)
    case wait(Wait)
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
    let answers: [Detail]
    let maxSize: Int
    let maxTimeoutSeconds: Double

    public init?(_ template: Template, patterns: [ExtractionPattern], answers: [Detail], maxSize: Int, maxTimeoutSeconds: Double)
    {
        guard patterns.count == answers.count else
        {
            return nil
        }

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
        self.answers = answers
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
