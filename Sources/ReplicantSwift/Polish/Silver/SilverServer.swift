//
//  SilverServerModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import Transport
import Logging

#if (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
import CryptoKit
#else
import Crypto
#endif

public class SilverServer
{
    public let controller: SilverController
    
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    public var clientPublicKey: P256.KeyAgreement.PublicKey?
    
    let log: Logger
    
    public init?(logger: Logger, chunkSize: UInt16, chunkTimeout: Int, clientPublicKeyData: Data? = nil)
    {
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        self.log = logger
        self.controller = SilverController(logger: logger)
        
        // The client's key if we get one on init
        if let publicKeyData = clientPublicKeyData
        {
           if let cPublicKey = controller.decodeKey(fromData: publicKeyData)
           {
                self.clientPublicKey = cPublicKey
           }
        }
        
        // Check to see if the server already has a keypair first
        // If not, create one.
        guard let newKeyPair = controller.fetchOrCreateServerKeyPair()
            else
        {
            return nil
        }
        
        self.privateKey = newKeyPair.privateKey
        self.publicKey = newKeyPair.publicKey
    }
    
    deinit
    {
        controller.deleteClientKeys()
    }
}

extension SilverServer: PolishServer
{
    public func newConnection(connection: Connection) -> PolishConnection?
    {
        return SilverServerConnection(logger: log, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    }
 
}
