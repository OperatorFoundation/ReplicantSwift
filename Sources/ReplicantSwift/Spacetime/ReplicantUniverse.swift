//
//  ReplicantUniverse.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation
import Logging

import Ghostwriter
import Spacetime
import TransmissionTypes
import Universe

public class ReplicantUniverse: Universe
{
    public func replicantListen(_ address: String, _ port: Int, config: ReplicantServerConfig, logger: Logger) throws -> UniverseListener
    {
        return try ReplicantUniverseListener(universe: self, address: address, port: port, config: config, logger: logger)
    }

    public func replicantConnect(_ address: String, _ port: Int, config: ReplicantClientConfig, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        let network = try super.connect(address, port)

        guard let connection = network as? ConnectConnection else
        {
            throw ReplicantUniverseError.wrongConnectionType
        }

        return try connection.replicantClientTransformation(config, logger)
    }
}

extension ListenConnection
{
    public func replicantServerTransformation(_ config: ReplicantServerConfig, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        var result: TransmissionTypes.Connection = self
        
        // TODO: Add more ToneBurst types as they become available
        if let starBurst = config.toneBurst as? Starburst
        {
            try starBurst.perform(connection: self)
        }

        if let polishConfig = config.polish
        {
            result = try polishConfig.polish(result, logger)
        }

        return result
    }
}

extension ConnectConnection
{
    public func replicantClientTransformation(_ config: ReplicantClientConfig, _ logger: Logger) throws -> TransmissionTypes.Connection
    {
        var result: TransmissionTypes.Connection = self

        if let starBurst = config.toneBurst as? Starburst
        {
            try starBurst.perform(connection: self)
        }

        if let polishConfig = config.polish
        {
            result = try polishConfig.polish(result, logger)
        }

        return result
    }
}

public enum ReplicantUniverseError: Error
{
    case wrongConnectionType

    // Starburst
    case speakFailed
    case listenFailed
    case wrongResultType
    case waitFailed
}
