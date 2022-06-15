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

public enum PolishServerConfig: Codable
{
    case darkStar(ShadowConfig)
}

extension PolishServerConfig: PolishConfig
{
    public func polish(_ connection: TransmissionTypes.Connection, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        switch self
        {
            case .darkStar(let config):
                guard let ipv4 = IPv4Address(config.serverIP) else
                {
                    throw PolishServerConfigError.notV4Address(config.serverIP)
                }

                let endpoint = NWEndpoint.hostPort(host: NWEndpoint.Host.ipv4(ipv4), port: NWEndpoint.Port(integerLiteral: config.port))
                // FIXME
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
}

public enum PolishServerConfigError: Error
{
    case nullDarkStarConnection
    case notV4Address(String)
    case transportToTransmissionFailed
}
