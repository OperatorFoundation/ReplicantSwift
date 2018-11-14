//
//  CryptoHandshake.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation
import Datable
import CommonCrypto

/**
 The client will need to know the server’s public key as part of the configuration. The server will not know the client’s public key, so the first thing the client will need to send is it’s public key. After that, it will just send encrypted data. Please note that the client public key when exported to a Data from CommonCrypto will be 65 bytes, where the first byte is always 4. This should be stripped off to remove the redundant 4 and just the remaining 64 bytes should be sent. The key size should then be padded to be the size of one chunk.
 The server will then send a response which is the size of one chunk, and which contains random bytes that should be discarded.
*/
class CryptoHandshake: NSObject
{
    let encryptor = Encryption()
    
    /// The client will need to know the server’s public key as part of the configuration.
    var serverPublicKey: Data
    
    /// The client public key when exported to a Data from CommonCrypto will be 65 bytes, where the first byte is always 4. This should be stripped off to remove the redundant 4 and just the remaining 64 bytes should be sent. The key size should then be padded to be the size of one chunk.
    var clientPublicKey: Data
    
    init?(withKeyData clientKeyData: Data, andServerKeyData serverKeyData: Data)
    {
        guard let allDressedUp = encryptor.cleanAndPadKey(keyData: clientKeyData)
        else
        {
            return nil
        }
        
        clientPublicKey = allDressedUp
        serverPublicKey = serverKeyData
    }
    
    init?(withKey clientKey: SecKey, andServerKeyData serverKeyData: Data)
    {
        var error: Unmanaged<CFError>?
        
        // Encode public key as data
        guard let clientPublicData = SecKeyCopyExternalRepresentation(clientKey, &error) as Data?
            else
        {
            print("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        //FIXME: Padding
        guard let cleanClientPublicData = encryptor.cleanAndPadKey(keyData: clientPublicData)
        else
        {
            return nil
        }
        
        clientPublicKey = cleanClientPublicData
        serverPublicKey = serverKeyData
    }

    
}


