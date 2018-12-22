//
//  PolishClientModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation

public class PolishClientModel
{
    public let controller = PolishController()
    
    public var serverPublicKey: SecKey
    public var publicKey: SecKey
    public var privateKey: SecKey
    
    public init?(serverPublicKeyData: Data)
    {
        controller.deleteKeys()
        
        guard let sPublicKey = controller.decodeKey(fromData: serverPublicKeyData)
        else
        {
            return nil
        }

        guard let newKeyPair = controller.generateKeyPair(withAttributes: controller.generateKeyAttributesDictionary())
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
        controller.deleteKeys()
    }
}
