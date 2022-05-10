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
}

public struct Speak: Codable
{
    let template: Template
    let details: [Detail]

    public init(_ template: Template, _ details: [Detail])
    {
        self.template = template
        self.details = details
    }
}

public struct Listen: Codable
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
