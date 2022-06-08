//
//  ReplicantUniverse.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime
import TransmissionTypes
import Universe

public class ReplicantUniverse: Universe
{
    public func replicantListen(_ address: String, _ port: Int, config: ReplicantServerConfig) throws -> UniverseListener
    {
        return try ReplicantUniverseListener(universe: self, address: address, port: port, config: config)
    }

    public func replicantConnect(_ address: String, _ port: Int, config: ReplicantClientConfig) -> TransmissionTypes.Connection?
    {
        do
        {
            let network = try super.connect(address, port)

            guard let connection = network as? ConnectConnection else
            {
                return nil
            }

            return connection.replicantClientTransformation(config)
        }
        catch
        {
            print(error)
            return nil
        }
    }
}

extension ListenConnection
{
    public func replicantServerTransformation(_ config: ReplicantServerConfig) -> TransmissionTypes.Connection?
    {
        var result = self

        if let toneBurstConfig = config.toneBurst
        {
            var toneBurst = toneBurstConfig.getToneBurst()
            do
            {
                try toneBurst.perform(connection: self)
            }
            catch
            {
                print(error)
                return nil
            }
        }

        if let polishConfig = config.polish
        {
            result = polishConfig.polish(result, self.logger)
        }

        return result
    }
}

extension ConnectConnection
{
    public func replicantClientTransformation(_ config: ReplicantClientConfig) -> TransmissionTypes.Connection?
    {
        var result = self

        if let toneBurstConfig = config.toneBurst
        {
            var toneBurst = toneBurstConfig.getToneBurst()
            do
            {
                try toneBurst.perform(connection: self)
            }
            catch
            {
                print(error)
                return nil
            }
        }

        if let polishConfig = config.polish
        {
            result = polishConfig.polish(result, self.logger)
        }

        return result
    }
}
