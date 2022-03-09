//
//  ReplicantListener.swift
//  ReplicantSwiftServer
//
//  Created by Adelita Schule on 11/29/18.
//

import Foundation
import Logging

import SwiftQueue
import Net
import Transmission

public class ReplicantListener: Transmission.Listener
{
    var debugDescription: String = "[ReplicantTCPListener]"
    var parameters: NWParameters
    var port: Int
    var queue: DispatchQueue? = DispatchQueue(label: "Replicant Server Queue")
    let logger: Logger
    
    var config: ReplicantServerConfig
    var listener: TransmissionListener    
   
    required public init?(port: Int, replicantConfig: ReplicantServerConfig, logger: Logger)
    {
        self.parameters = .tcp
        self.config = replicantConfig
        self.port = port
        self.logger = logger
        
        // Create the listener
        guard let listener = TransmissionListener(port: port, logger: logger) else
        {
            print("\n😮  Listener creation error  😮\n")
            return nil
        }
        self.listener = listener
    }
    
    public func accept() -> Transmission.Connection {
        while true
        {
            let networkConnection = self.listener.accept()
            
            guard let replicantConnection = makeReplicant(connection: networkConnection) else
            {
                print("Unable to convert new connection to a Replicant connection.")
                continue
            }
            
            return replicantConnection
        }
    }
    
    func makeReplicant(connection: Transmission.Connection) -> Transmission.Connection?
    {
        let newConnection = ReplicantServerConnection(connection: connection, parameters: .tcp, replicantConfig: config, logger: logger)
        
        if newConnection == nil
        {
            print("\nReplicant connection factory returned a nil connection object.")
        }
        
        return newConnection
    }
}

enum ListenerError: Error
{
    case invalidPort
    case initializationError
}
