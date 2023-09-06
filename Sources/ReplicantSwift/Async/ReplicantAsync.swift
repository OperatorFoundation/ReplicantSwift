//
//  Replicant.swift
//
//
//  Created by Dr. Brandon Wiley on 6/14/22.
//

import Foundation

import Logging
import TransmissionAsync

public class ReplicantAsync
{
    var logger: Logger

    public init(logger: Logger)
    {
        self.logger = logger
    }

    public func listen(address: String, port: Int, config: ReplicantServerConfig) async throws -> TransmissionAsync.AsyncListener
    {
        return try ReplicantListenerAsync(address: address, port: port, config: config, logger: logger)
    }

    public func connect(host: String, port: Int, config: ReplicantClientConfig) async throws -> TransmissionAsync.AsyncConnection
    {
        let network = try await AsyncTcpSocketConnection(host, port, logger)

        return try await self.replicantClientTransformationAsync(connection: network, config, logger)
        
    }
    
    public func replicantClientTransformationAsync(connection: TransmissionAsync.AsyncConnection, _ config: ReplicantClientConfig, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {
        var result: TransmissionAsync.AsyncConnection = connection

        if let starBurst = config.toneBurst as? StarburstAsync
        {
            try await starBurst.perform(connection: connection)
        }

        if let polishConfig = config.polish
        {
            result = try await polishConfig.polish(result, logger)
        }

        return result
    }
}