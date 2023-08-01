//
//  PolishClientConfig.swift
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

extension PolishClientConfig: PolishAsync
{
    public func polish(_ connection: TransmissionAsync.AsyncConnection, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {        
        let config = ShadowConfig.ShadowClientConfig(serverAddress: self.serverAddress, serverPublicKey: self.serverPublicKey, mode: .DARKSTAR)
        return try await AsyncDarkstarClientConnection(connection, config, logger)
    }
}
