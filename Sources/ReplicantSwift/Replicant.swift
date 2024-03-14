//
//  Replicant.swift
//
//
//  Created by Dr. Brandon Wiley on 6/14/22.
//

import Foundation

import Logging
import TransmissionAsync

public class Replicant
{
    var logger: Logger

    public init(logger: Logger)
    {
        self.logger = logger
    }

    public func listen(serverIP: String, port: Int, config: ReplicantConfig.ServerConfig) async throws -> TransmissionAsync.AsyncListener
    {
        return try ReplicantListener(config: config, logger: logger)
    }

    public func connect(host: String, port: Int, config: ReplicantConfig.ClientConfig) async throws -> TransmissionAsync.AsyncConnection
    {
        let network = try await AsyncTcpSocketConnection(host, port, logger)
        return try await self.replicantClientTransformation(connection: network, config: config, logger: logger)
    }
    
    public func replicantClientTransformation(connection: TransmissionAsync.AsyncConnection, config: ReplicantConfig.ClientConfig, logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {
        var result: TransmissionAsync.AsyncConnection = connection
        
        switch config.toneburstType 
        {
            case .starburst:
                switch config.toneburst
                {
                    case let starBurst as Starburst:
                        try await starBurst.perform(connection: connection)

                    case let omnitone as Omnitone:
                        try await omnitone.perform(connection: connection)

                    default:
                        throw ReplicantError.invalidToneburst
                }

            case .none:
                print("replicantClientTransformationAsync skipping Toneburst: none provided")
        }
        

        if let polishConfig = config.polish
        {
            result = try await polishConfig.polish(result, logger)
        }

        return result
    }
}
