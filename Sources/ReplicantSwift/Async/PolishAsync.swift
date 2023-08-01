//
//  File.swift
//
//
//  Created by Mafalda on 1/19/22.
//

import Foundation

import Logging
import TransmissionAsync

public protocol PolishAsync
{
    func polish(_ connection: TransmissionAsync.AsyncConnection, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
}
