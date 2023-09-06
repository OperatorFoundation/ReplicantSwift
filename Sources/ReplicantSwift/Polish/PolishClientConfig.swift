//
//  PolishClientConfig.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

#if os(macOS) || os(iOS)
import os.log
#else
import Logging
#endif

import KeychainTypes
import Net
import ShadowSwift
import TransmissionTypes
import TransmissionTransport

public class PolishClientConfig: Codable
{
    public let serverAddress: String
    public let serverPublicKey: PublicKey
    
    public init(serverAddress: String, serverPublicKey: PublicKey) {
        self.serverAddress = serverAddress
        self.serverPublicKey = serverPublicKey
    }
}

extension PolishClientConfig: PolishConfig
{
    public func polish(_ connection: TransmissionTypes.Connection, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        let addressArray = self.serverAddress.split(separator: ":")
        let host = String(addressArray[0])
        guard let port = UInt16(addressArray[1]) else {
            throw PolishClientConfigError.invalidPort
        }
        
        guard let ipv4 = IPv4Address(host) else
        {
            throw PolishClientConfigError.notV4Address(host)
        }

        let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipv4), port: NWEndpoint.Port(integerLiteral: port))
        let config = try ShadowConfig.ShadowClientConfig(serverAddress: self.serverAddress, serverPublicKey: self.serverPublicKey, mode: .DARKSTAR)
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
    case invalidPort
    case notV4Address(String)
    case transportToTransmissionFailed
}
