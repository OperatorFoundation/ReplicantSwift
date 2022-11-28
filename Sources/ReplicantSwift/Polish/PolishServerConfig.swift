//
//  PolishServerConfig.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation
import Logging

import Net
import ShadowSwift
import TransmissionTypes
import TransmissionTransport

public class PolishServerConfig: Codable
{
    public let serverAddress: String
    public let serverPrivateKey: String
    
    init(serverAddress: String, serverPrivateKey: String) {
        self.serverAddress = serverAddress
        self.serverPrivateKey = serverPrivateKey
    }
}

extension PolishServerConfig: PolishConfig
{
    public func polish(_ connection: TransmissionTypes.Connection, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        let addressArray = self.serverAddress.split(separator: ":")
        let host = addressArray[0].base
        let port = addressArray[1].base
        let portUint = port.uint16
        guard let ipv4 = IPv4Address(host) else
        {
            throw PolishServerConfigError.notV4Address(host)
        }

        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipv4), port: NWEndpoint.Port(integerLiteral: portUint))
        let config = ShadowConfig.ShadowServerConfig(serverAddress: self.serverAddress, serverPrivateKey: self.serverPrivateKey, mode: .DARKSTAR, transport: "shadow")
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
    case nullDarkStarConnection
    case notV4Address(String)
    case transportToTransmissionFailed
}
