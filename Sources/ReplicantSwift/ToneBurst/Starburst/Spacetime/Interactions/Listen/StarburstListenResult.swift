//
//  ListenResult.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Ghostwriter

public enum StarburstListenResult: Codable, CustomStringConvertible
{
    public var description: String
    {
        switch self
        {
            case .data(let value):
                return "StarburstListenResult.data(\(value.description))"

            case .text(let value):
                return "StarburstListenResult.text(\(value.description))"

            case .parse(let value):
                return "StarburstListenResult.parse(\(value.description))"

            case .match:
                return "StartburstListenResult.match"
        }
    }

    case data(Data)
    case text(String)
    case parse([Detail])
    case match
}
