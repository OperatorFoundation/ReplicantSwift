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
import TransmissionTypes
import TransmissionTransport

public class PolishServerConfig: Codable
{
    public let serverAddress: String
    public let serverPrivateKey: PrivateKey
    
    public init(serverAddress: String, serverPrivateKey: PrivateKey) {
        self.serverAddress = serverAddress
        self.serverPrivateKey = serverPrivateKey
    }
}

extension PolishServerConfig: PolishConfig
{
    public func polish(_ connection: TransmissionTypes.Connection, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        let addressArray = self.serverAddress.split(separator: ":")
        let host = String(addressArray[0])
        guard let port = UInt16(addressArray[1]) else {
            throw PolishServerConfigError.invalidPort
        }
        guard let ipv4 = IPv4Address(host) else
        {
            throw PolishServerConfigError.notV4Address(host)
        }

        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipv4), port: NWEndpoint.Port(integerLiteral: port))
        let config = ShadowConfig.ShadowServerConfig(serverAddress: self.serverAddress, serverPrivateKey: self.serverPrivateKey, mode: .DARKSTAR, transport: "Shadow")
        guard let result = DarkStarServerConnection(connection: connection, endpoint: endpoint, parameters: .tcp, config: config, logger: logger) else
        {
            throw PolishServerConfigError.nullDarkStarConnection
        }

        guard let transmission = TransportToTransmissionConnection({return result}) else
        {
            throw PolishServerConfigError.transportToTransmissionFailed
        }

        return transmission
    }
}

public enum PolishServerConfigError: Error
{
    case invalidPort
    case nullDarkStarConnection
    case notV4Address(String)
    case transportToTransmissionFailed
}
