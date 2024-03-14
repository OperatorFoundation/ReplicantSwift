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
open class ReplicantListener: TransmissionAsync.AsyncListener
{
    let config: ReplicantConfig.ServerConfig
    let logger: Logger
    let listener: AsyncListener

    public init(config: ReplicantConfig.ServerConfig, logger: Logger) throws
    {
        self.config = config
        self.logger = logger
        self.listener = try AsyncTcpSocketListener(host: config.serverIP, port: Int(config.serverPort), logger)
    }

    open func accept() async throws -> TransmissionAsync.AsyncConnection
    {
        let network = try await self.listener.accept()
        return try await self.replicantServerTransformation(connection: network, config: config, logger: logger)
    }

    open func close() async throws
    {
        try await self.listener.close()
    }

    public func replicantServerTransformation(connection: TransmissionAsync.AsyncConnection, config: ReplicantConfig.ServerConfig, logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {
        var result: TransmissionAsync.AsyncConnection = connection

        // TODO: Add more ToneBurst types as they become available
        switch config.toneburstType
        {
            case .starburst:
                if let starburst = config.toneburst as? Starburst
                {
                    try await starburst.perform(connection: connection)
                }
                else if let starburst = config.toneburst as? Omnitone
                {
                    try await starburst.perform(connection: connection)
                }
                else
                {
                    logger.error("Invalid Replicant Server Config toneburst type is starburst, but toneburst could not be initialized.")
                    throw ReplicantError.invalidToneburst
                }
            case .none:
                print("ReplicantServerTransformation: Skipping Toneburst.")
        }
        
        if let polishConfig = config.polish
        {
            result = try await polishConfig.polish(result, logger)
        }

        return result
    }
}
