//
//  SilverServerModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import SwiftQueue

public class SilverServerModel
{
    public let controller: ChromeController
    
    public var clientPublicKey: SecKey?
    public var publicKey: SecKey
    public var privateKey: SecKey
    
    
    public init?(clientPublicKeyData: Data? = nil, logQueue: Queue<String>)
    {
        controller = ChromeController(logQueue: logQueue)
        
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
