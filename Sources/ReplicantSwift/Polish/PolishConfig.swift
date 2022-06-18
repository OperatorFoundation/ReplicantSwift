//
//  File.swift
//  
//
//  Created by Mafalda on 1/19/22.
//

import Foundation
import Logging

import Net
import TransmissionTypes

public protocol PolishConfig
{
    func polish(_ connection: TransmissionTypes.Connection, _ logger: Logger) throws -> TransmissionTypes.Connection
}

public enum PolishType: String, Codable
{
    case darkStar = "DarkStar"
}

