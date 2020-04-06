//
//  SilverClientModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import SwiftQueue
import CryptoKit

public class SilverClientModel
{
    public let controller: SilverController
    public let salt: Data
    
    public var serverPublicKey: P256.KeyAgreement.PublicKey
    public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    
    public init?(salt: Data, logQueue: Queue<String>, serverPublicKeyData: Data)
    {
        self.salt = salt
        self.controller = SilverController(logQueue: logQueue)
        controller.deleteClientKeys()
        
        guard let sPublicKey = controller.decodeKey(fromData: serverPublicKeyData)
        else
        {
            return nil
        }

        let clientPrivateKey = P256.KeyAgreement.PrivateKey()
        let clientPublicKey = clientPrivateKey.publicKey
        
        self.serverPublicKey = sPublicKey
        self.privateKey = clientPrivateKey
        self.publicKey = clientPublicKey
    }
    
    deinit
    {
        controller.deleteClientKeys()
    }
}
