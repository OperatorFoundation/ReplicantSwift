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

    public func listen(serverIP: String, port: Int, config: ReplicantConfigAsync.ServerConfig) async throws -> TransmissionAsync.AsyncListener
    {
        return try ReplicantListenerAsync(config: config, logger: logger)
    }

    public func connect(host: String, port: Int, config: ReplicantConfigAsync.ClientConfig) async throws -> TransmissionAsync.AsyncConnection
    {
        let network = try await AsyncTcpSocketConnection(host, port, logger)
        return try await self.replicantClientTransformationAsync(connection: network, config: config, logger: logger)
    }
    
    public func replicantClientTransformationAsync(connection: TransmissionAsync.AsyncConnection, config: ReplicantConfigAsync.ClientConfig, logger: Logger) async throws -> TransmissionAsync.AsyncConnection
    {
        var result: TransmissionAsync.AsyncConnection = connection
        
        switch config.toneburstType 
        {
            case .starburst:
                guard let starBurst = config.toneburst as? StarburstAsync else
                {
                    throw ReplicantError.invalidToneburst
                }
                try await starBurst.perform(connection: connection)
                
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
