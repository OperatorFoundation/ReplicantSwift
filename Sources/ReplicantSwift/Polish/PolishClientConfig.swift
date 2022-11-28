//
//  PolishClientConfig.swift
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

public class PolishClientConfig: Codable
{
    public let serverAddress: String
    public let serverPublicKey: String
    
    public init(serverAddress: String, serverPublicKey: String) {
        self.serverAddress = serverAddress
        self.serverPublicKey = serverPublicKey
    }
}

extension PolishClientConfig: PolishConfig
{
    public func polish(_ connection: TransmissionTypes.Connection, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        let addressArray = self.serverAddress.split(separator: ":")
        let host = addressArray[0].base
        let port = addressArray[1].base
        let portUint = port.uint16
        guard let ipv4 = IPv4Address(host) else
        {
            throw PolishClientConfigError.notV4Address(host)
        }

        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipv4), port: NWEndpoint.Port(integerLiteral: portUint))
        let config = ShadowConfig.ShadowClientConfig(serverAddress: self.serverAddress, serverPublicKey: self.serverAddress, mode: .DARKSTAR, transport: "shadow")
        guard let result = DarkStarClientConnection(connection: connection, endpoint: endpoint, parameters: .tcp, config: config, logger: logger) else
        {
            throw PolishClientConfigError.nullDarkStarConnection
        }

        guard let transmission = TransportToTransmissionConnection({return result}) else
        {
            throw PolishClientConfigError.transportToTransmissionFailed
        }

        return transmission
        
    }
}

public enum PolishClientConfigError: Error
{
    case nullDarkStarConnection
    case notV4Address(String)
    case transportToTransmissionFailed
}
