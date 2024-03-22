//
//  PolishClientConfig.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation
import Logging

import KeychainTypes
import ShadowSwift
import TransmissionAsync

public class PolishClientConfig: Codable
{
    public let serverAddress: String
    public let serverPublicKey: PublicKey
    
    public init(serverAddress: String, serverPublicKey: PublicKey) {
        self.serverAddress = serverAddress
        self.serverPublicKey = serverPublicKey
    }
}

extension PolishClientConfig: Polish
{
    public func polish(_ connection: TransmissionAsync.AsyncConnection, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {
        let config = try ShadowConfig.ShadowClientConfig(serverAddress: self.serverAddress, serverPublicKey: self.serverPublicKey, mode: .DARKSTAR)
        return try await AsyncDarkstarClientConnection(connection, config, logger)
    }
}

public enum PolishClientConfigError: Error
{
    case nullDarkStarConnection
    case invalidPort
    case notV4Address(String)
    case transportToTransmissionFailed
}
