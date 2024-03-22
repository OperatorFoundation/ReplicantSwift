//
//  PolishServerConfig.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation
import Logging

import KeychainTypes
import ShadowSwift
import TransmissionAsync

public class PolishServerConfig: Codable
{
    public let serverAddress: String
    public let serverPrivateKey: PrivateKey
    
    public init(serverAddress: String, serverPrivateKey: PrivateKey) {
        self.serverAddress = serverAddress
        self.serverPrivateKey = serverPrivateKey
    }
}

extension PolishServerConfig: Polish
{
    public func polish(_ connection: TransmissionAsync.AsyncConnection, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {
        let config = try ShadowConfig.ShadowServerConfig(serverAddress: self.serverAddress, serverPrivateKey: self.serverPrivateKey, mode: .DARKSTAR)
        return try await AsyncDarkstarServerConnection(connection, config, logger)
    }
}

public enum PolishServerConfigError: Error
{
    case invalidPort
    case nullDarkStarConnection
    case notV4Address(String)
    case transportToTransmissionFailed
}
