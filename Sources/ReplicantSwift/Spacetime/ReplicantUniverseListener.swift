//
//  ReplicantUniverseListener.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime
import TransmissionTypes
import Universe

// This is just a normal TCP listener, except for the config and special accept behavior.
open class ReplicantUniverseListener: UniverseListener
{
    let config: ReplicantServerConfig

    public init(universe: Universe, address: String, port: Int, config: ReplicantServerConfig) throws
    {
        self.config = config

        try super.init(universe: universe, address: address, port: port)
    }

    override open func accept() -> TransmissionTypes.Connection?
    {
        guard let network = super.accept() else
        {
            return nil
        }

        guard let connection = network as? ListenConnection else
        {
            return nil
        }

        return connection.replicantServerTransformation(config)
    }
}
