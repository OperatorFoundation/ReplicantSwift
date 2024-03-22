//
//  File.swift
//
//
//  Created by Mafalda on 1/19/22.
//

import Foundation

import Logging
import TransmissionAsync

public protocol Polish
{
    func polish(_ connection: TransmissionAsync.AsyncConnection, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
}

public enum PolishType: String, Codable
{
    case darkStar = "DarkStar"
}
