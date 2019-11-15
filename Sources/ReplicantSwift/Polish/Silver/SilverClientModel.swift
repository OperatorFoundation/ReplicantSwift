//
//  SilverClientModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import SwiftQueue

public class SilverClientModel
{
    public let controller: SilverController
    
    public var serverPublicKey: SecKey
    public var publicKey: SecKey
    public var privateKey: SecKey
    
    public init?(serverPublicKeyData: Data, logQueue: Queue<String>)
    {
        self.controller = SilverController(logQueue: logQueue)
        controller.deleteClientKeys()
        
        guard let sPublicKey = controller.decodeKey(fromData: serverPublicKeyData)
        else
        {
            return nil
        }

        guard let newKeyPair = controller.generateKeyPair(withAttributes: controller.generateClientKeyAttributesDictionary())
            else
        {
            return nil
        }
        
        self.serverPublicKey = sPublicKey
        self.privateKey = newKeyPair.privateKey
        self.publicKey = newKeyPair.publicKey
    }
    
    deinit
    {
        controller.deleteClientKeys()
    }
}
