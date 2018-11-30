//
//  Polish.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation
import Security
import CommonCrypto

public let keySize = 64
public let aesOverheadSize = 81

public class Polish: NSObject
{
    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
    public var serverPublicKey: SecKey
    public var clientPublicKey: SecKey
    public var clientPrivateKey: SecKey
    
    public init?(serverPublicKey: SecKey)
    {
        guard let newKeyPair = Polish.generateKeyPair()
        else
        {
            return nil
        }
        
        self.clientPrivateKey = newKeyPair.privateKey
        self.clientPublicKey = newKeyPair.publicKey
        self.serverPublicKey = serverPublicKey
    }
    
    deinit
    {
        //TODO: Remove client keys from secure enclave
    }
    
    static func generatePrivateKey() -> SecKey?
    {
        // Generate private key
        let tag = "org.operatorfoundation.replicant.client".data(using: .utf8)!
        
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                            .privateKeyUsage,
                                            nil)!
        
        let privateKeyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: tag
            /*kSecAttrAccessControl as String: access*/
        ]
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            /*kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,*/
            kSecPrivateKeyAttrs as String: privateKeyAttributes
        ]
        
        var error: Unmanaged<CFError>?
        guard let alicePrivate = SecKeyCreateRandomKey(attributes as CFDictionary, &error)
            else
        {
            print("\nUnable to generate the client private key: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return alicePrivate
    }
    
    static func generatePublicKey(usingPrivateKey privateKey: SecKey) -> SecKey?
    {
        guard let alicePublic = SecKeyCopyPublicKey(privateKey)
            else
        {
            print("\nUnable to generate a public key from the provided private key.\n")
            return nil
        }
        
        return alicePublic
    }
    
    static func generateKeyPair() -> (privateKey: SecKey, publicKey: SecKey)?
    {
        guard let privateKey = generatePrivateKey()
        else
        {
            return nil
        }
        
        guard let publicKey = generatePublicKey(usingPrivateKey: privateKey)
        else
        {
            return nil
        }
        
        return (privateKey, publicKey)
    }
    
    /// This is the format needed to send the key to the server.
    public func generateAndEncryptPaddedKeyData(fromKey key: SecKey, withChunkSize chunkSize: Int, usingServerKey serverKey: SecKey) -> Data?
    {
        var error: Unmanaged<CFError>?
        var newKeyData: Data
        
        // Encode key as data
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data?
            else
        {
            print("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        newKeyData = keyData
        
        // Add padding if needed
        if let padding = getKeyPadding(chunkSize: chunkSize)
        {
            newKeyData = keyData + padding
        }
        
        // Encrypt the key
        guard let encryptedKeyData = encrypt(payload: newKeyData, usingServerKey: serverKey)
        else
        {
            return nil
        }
        
        return encryptedKeyData
    }
    
    /// Decode data to get public key. This only decodes key data that is NOT padded.
    static func decodeKey(fromData publicKeyData: Data) -> SecKey?
    {
        var error: Unmanaged<CFError>?
        
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                      kSecAttrKeySizeInBits as String: 256]
        
        guard let decodedBobPublicKey = SecKeyCreateWithData(publicKeyData as CFData, options as CFDictionary, &error)
            else
        {
            print("\nUnable to decode server public key: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return decodedBobPublicKey
    }
    
    /// Encrypt payload
    public func encrypt(payload: Data, usingServerKey serverPublicKey: SecKey) -> Data?
    {
        var error: Unmanaged<CFError>?
        
        guard let cipherText = SecKeyCreateEncryptedData(serverPublicKey, algorithm, payload as CFData, &error) as Data?
            else
        {
            print("\nUnable to encrypt payload: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return cipherText
    }
    
    /// Decrypt payload
    /// - Parameter payload: Data
    /// - Parameter privateKey: SecKey
    public func decrypt(payload: Data, usingPrivateKey privateKey: SecKey) -> Data?
    {
        var error: Unmanaged<CFError>?
        
        guard let decryptedText = SecKeyCreateDecryptedData(privateKey, algorithm, payload as CFData, &error) as Data?
            else
        {
            print("\nUnable to decrypt payload: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return decryptedText
    }
    
    func getKeyPadding(chunkSize: Int) -> Data?
    {
        let paddingSize = chunkSize - (keySize + aesOverheadSize)
        if paddingSize > 0
        {
            let bytes = [UInt8](repeating: 0, count: paddingSize)
            return Data(array: bytes)
        }
        else
        {
            return nil
        }
    }
}

