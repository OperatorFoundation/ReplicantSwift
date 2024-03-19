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
    let toneburst: ToneBurst?
    let polish: Polish?

    var logger: Logger
    

    public init(logger: Logger, polish: Polish?, toneburst: ToneBurst?)
    {
        self.logger = logger
        self.polish = polish
        self.toneburst = toneburst
    }

    public func listen(serverIP: String, port: Int) async throws -> TransmissionAsync.AsyncListener
    {
        return try ReplicantListener(replicant: self, serverIP: serverIP, serverPort: port, logger: self.logger)
    }

    public func connect(host: String, port: Int) async throws -> TransmissionAsync.AsyncConnection
    {
        let network = try await AsyncTcpSocketConnection(host, port, logger)
        return try await self.replicantClientTransformation(connection: network)
    }
    
    public func replicantClientTransformation(connection: TransmissionAsync.AsyncConnection) async throws -> TransmissionAsync.AsyncConnection
    {
        var result: TransmissionAsync.AsyncConnection = connection
        try await self.toneburst?.perform(connection: connection)

        if let polishConfig = self.polish
        {
            result = try await polishConfig.polish(result, logger)
        }

        return result
    }
}
