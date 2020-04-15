//
//  SilverServerModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import SwiftQueue
import CryptoKit

public class SilverServerModel
{
    public let controller: SilverController
    
    public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    public var clientPublicKey: P256.KeyAgreement.PublicKey?
    
    public init?(logQueue: Queue<String>, clientPublicKeyData: Data? = nil)
    {
        self.controller = SilverController(logQueue: logQueue)
        
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
