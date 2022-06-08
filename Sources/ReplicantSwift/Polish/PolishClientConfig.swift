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

public enum PolishClientConfig: Codable
{
    case darkStar(ShadowConfig)
}

extension PolishClientConfig: PolishConfig
{
    public func polish(_ connection: TransmissionTypes.Connection, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        switch self
        {
            case .darkStar(let config):
                guard let ipv4 = IPv4Address(config.serverIP) else
                {
                    throw PolishClientConfigError.notV4Address(config.serverIP)
                }

                let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipv4), port: NWEndpoint.Port(integerLiteral: config.port))
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
}

public enum PolishClientConfigError: Error
{
    case nullDarkStarConnection
    case notV4Address(String)
    case transportToTransmissionFailed
}
