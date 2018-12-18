//
//  PolishServerModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation

public class PolishServerModel
{
    let controller = PolishController()
    
    public var publicKey: SecKey
    public var privateKey: SecKey
    
    
    public init?()
    {
        controller.deleteKeys()
        
        guard let newKeyPair = controller.generateKeyPair()
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
