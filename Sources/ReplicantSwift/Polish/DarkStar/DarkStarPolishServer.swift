//
//  SilverServerModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import Transmission
import Logging

import Crypto

public class DarkStarPolishServer: Polish
{
    public let controller: DarkStarPolishController
    
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    public var clientPublicKey: P256.KeyAgreement.PublicKey?
    
    var log: Logger
        
    public init?(logger: Logger, chunkSize: UInt16, chunkTimeout: Int, clientPublicKeyData: Data? = nil)
    {
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        self.log = logger
        
        guard let maybeController = DarkStarPolishController(logger: logger)
        else { return nil }
        self.controller = maybeController
        
        // The client's key if we get one on init
        if let publicKeyData = clientPublicKeyData
        {
           if let cPublicKey = controller.decodeKey(fromData: publicKeyData)
           {
                self.clientPublicKey = cPublicKey
           }
        }
    }
}

extension DarkStarPolishServer: PolishServer
{
    public func newConnection(connection: Connection) -> PolishConnection?
    {
        return DarkStarPolishServerConnection(logger: log, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    }
 
}
