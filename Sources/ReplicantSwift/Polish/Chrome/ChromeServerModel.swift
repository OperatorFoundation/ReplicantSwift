//
//  PolishServerModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation
import SwiftQueue
import CryptoKit

public class ChromeServerModel
{
    public let controller: ChromeController
    
    let clientPublicEphemeralEncryptionKey: P256.KeyAgreement.PublicKey
    let serverPrivateEncryptionKey: PrivateEncryptionKey
    
    public init(publicEncryptionKeyData: Data, privateEncryption: PrivateEncryptionKey, logQueue: Queue<String>) throws
    {
        self.controller = ChromeController(logQueue: logQueue)
        self.clientPublicEphemeralEncryptionKey = try P256.KeyAgreement.PublicKey(rawRepresentation: publicEncryptionKeyData)
        self.serverPrivateEncryptionKey = privateEncryption
    }
    
    public init?(clientPublicKeyData: Data? = nil, logQueue: Queue<String>)
    {
        controller = ChromeController(logQueue: logQueue)
        
        // The client's key if we get one on init
        if let publicKeyData = clientPublicKeyData
        {
           if let cPublicKey = controller.decodeKey(fromData: publicKeyData)
           {
                self.clientPublicEphemeralEncryptionKey = cPublicKey
           }
        }
        
        // Check to see if the server already has a keypair first
        // If not, create one.
        guard let newServerKey = controller.fetchOrCreateServerKeyPair()
            else
        {
            return nil
        }
        
        self.serverPrivateEncryptionKey = newServerKey
    }
    
    deinit
    {
        controller.deleteClientKeys()
    }
}
