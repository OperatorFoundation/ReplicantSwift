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
    let replicant: Replicant
    let logger: Logger
    let listener: AsyncListener

    public init(replicant: Replicant, serverIP: String, serverPort: Int, logger: Logger) throws
    {
        self.replicant = replicant
        self.logger = logger
        self.listener = try AsyncTcpSocketListener(host: serverIP, port: serverPort, logger)
    }

    open func accept() async throws -> TransmissionAsync.AsyncConnection
    {
        let network = try await self.listener.accept()
        return try await self.replicantServerTransformation(connection: network)
    }

    open func close() async throws
    {
        try await self.listener.close()
    }

    public func replicantServerTransformation(connection: TransmissionAsync.AsyncConnection) async throws -> TransmissionAsync.AsyncConnection
    {
        var result: TransmissionAsync.AsyncConnection = connection
        try await replicant.toneburst?.perform(connection: connection)
        
        if let polishConfig = replicant.polish
        {
            result = try await polishConfig.polish(result, logger)
        }

        return result
    }
}
