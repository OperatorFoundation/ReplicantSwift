//
//  PolishServerConfig.swift
//
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Logging

import KeychainTypes
import Net
import ShadowSwift
import TransmissionAsync

extension PolishServerConfig: PolishAsync
{
    public func polish(_ connection: TransmissionAsync.AsyncConnection, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {
        let config = ShadowConfig.ShadowServerConfig(serverAddress: self.serverAddress, serverPrivateKey: self.serverPrivateKey, mode: .DARKSTAR)
        return try await AsyncDarkstarServerConnection(connection, config, logger)
    }
}
