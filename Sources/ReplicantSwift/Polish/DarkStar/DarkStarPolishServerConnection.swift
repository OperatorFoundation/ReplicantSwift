//
//  SilverServerConnection.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Crypto
import Foundation
import Logging

import Net
import ShadowSwift
import Transmission

public class DarkStarPolishServerConnection
{
    public let controller: SilverController
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    //public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    public var symmetricKey: SymmetricKey?

    public let log: Logger
    
    public init?(logger: Logger, chunkSize: UInt16, chunkTimeout: Int)
    {
        self.log = logger
        guard let maybeController = SilverController(logger: logger)
        else { return nil }
        self.controller = maybeController
        
        // Check to see if the server already has a keypair first
        // If not, create one and save it.
        guard let serverPrivateKey = controller.fetchOrCreateServerKey()
            else
        {
            return nil
        }
        
        self.privateKey = serverPrivateKey
        //self.publicKey = clientPublicKey
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
    }
}

extension DarkStarPolishServerConnection: PolishConnection
{
    public func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    {
//        let shadowConfig = ShadowConfig(key: <#T##String#>, serverIP: <#T##String#>, port: <#T##UInt16#>, mode: <#T##CipherMode#>)
//        let darkStar = DarkStarClientConnection(connection: connection, endpoint: NWEndpoint, parameters: .tcp, config: ShadowConfig, logger: Logger)
        //FIXME
        return
    }
    
    public func polish(inputData: Data) -> Data?
    {
        //FIXME
        return nil
    }
    
    public func unpolish(polishedData: Data) -> Data?
    {
        //FIXME
        return nil
    }
}
