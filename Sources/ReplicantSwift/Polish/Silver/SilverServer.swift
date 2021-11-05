//
//  SilverServerModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import Transport
import Logging

import Crypto

public class SilverServer
{
    public let controller: SilverController
    
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    public var clientPublicKey: P256.KeyAgreement.PublicKey?
    
    let log: Logger
    
    public init?(logger: Logger, chunkSize: UInt16, chunkTimeout: Int, clientPublicKeyData: Data? = nil)
    {
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        self.log = logger
        
        guard let maybeController = SilverController(logger: logger)
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

extension SilverServer: PolishServer
{
    public func newConnection(connection: Connection) -> PolishConnection?
    {
        return SilverServerConnection(logger: log, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    }
 
}
