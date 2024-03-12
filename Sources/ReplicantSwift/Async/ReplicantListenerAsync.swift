//
//  ReplicantUniverseListener.swift
//
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Logging
import TransmissionAsync

// This is just a normal TCP listener, except for the config and special accept behavior.
open class ReplicantListenerAsync: TransmissionAsync.AsyncListener
{
    let config: ReplicantServerConfig
    let logger: Logger
    let listener: AsyncListener

    public init(serverIP: String, port: Int, config: ReplicantServerConfig, logger: Logger) throws
    {
        self.config = config
        self.logger = logger
        self.listener = try AsyncTcpSocketListener(host: serverIP, port: port, logger)
    }

    open func accept() async throws -> TransmissionAsync.AsyncConnection
    {
        let network = try await self.listener.accept()

        return try await self.replicantServerTransformation(connection: network, config, logger)
    }

    open func close() async throws
    {
        try await self.listener.close()
    }

    public func replicantServerTransformation(connection: TransmissionAsync.AsyncConnection, _ config: ReplicantServerConfig, _ logger: Logger) async throws -> TransmissionAsync.AsyncConnection
        {
            var result: TransmissionAsync.AsyncConnection = connection
    
            // TODO: Add more ToneBurst types as they become available
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
