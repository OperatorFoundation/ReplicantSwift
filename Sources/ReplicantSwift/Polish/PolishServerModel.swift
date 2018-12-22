//
//  PolishServerModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation

public class PolishServerModel
{
    public let controller = PolishController()
    
    public var clientPublicKey: SecKey?
    public var publicKey: SecKey
    public var privateKey: SecKey
    
    
    public init?(clientPublicKeyData: Data? = nil)
    {
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
        controller.deleteKeys()
    }
}
