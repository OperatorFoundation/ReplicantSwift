//
//  PolishClientModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation
import SwiftQueue

public class ChromeClientModel
{
    public let controller: ChromeController
    
    public var serverPublicKey: SecKey
    public var publicKey: SecKey
    public var privateKey: SecKey
    
    public init?(serverPublicKeyData: Data, logQueue: Queue<String>)
    {
        self.controller = ChromeController(logQueue: logQueue)
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
