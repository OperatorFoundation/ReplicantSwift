//
//  Replicant.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/14/22.
//

import Foundation
import Logging

import Simulation
import Spacetime
import TransmissionTypes
import Universe

public class Replicant
{
    var logger: Logger
    let simulation: Simulation
    let universe: ReplicantUniverse

    public init(logger: Logger)
    {
        self.logger = logger
        self.simulation = Simulation(capabilities: Capabilities(.display, .random, .networkConnect, .networkListen))
        
        // TODO: Update universe to accept Logger instead of os.Logger
        self.universe = ReplicantUniverse(effects: self.simulation.effects, events: self.simulation.events, logger: nil)
    }

    public func listen(address: String, port: Int, config: ReplicantServerConfig) throws -> TransmissionTypes.Listener
    {
        return try self.universe.replicantListen(address, port, config: config, logger: self.logger)
    }

    public func connect(host: String, port: Int, config: ReplicantClientConfig) throws -> TransmissionTypes.Connection
    {
        return try self.universe.replicantConnect(host, port, config: config, self.logger)
    }
}
