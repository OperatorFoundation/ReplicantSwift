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
    static let clientTag = "org.operatorfoundation.replicant.client".data(using: .utf8)!
    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
    
    public var recipientPublicKey: SecKey?
    public var publicKey: SecKey
    public var privateKey: SecKey
    
    public init?(recipientPublicKeyData: Data?)
    {
        Polish.deleteKeys()
        
        if let rPublicKeyData = recipientPublicKeyData
        {
            recipientPublicKey = Polish.decodeKey(fromData: rPublicKeyData)
        }
        
        guard let newKeyPair = Polish.generateKeyPair()
        else
        {
            return nil
        }
        
        self.privateKey = newKeyPair.privateKey
        self.publicKey = newKeyPair.publicKey
    }
    
    deinit
    {
        Polish.deleteKeys()
    }
    
    static func deleteKeys()
    {
        //Remove client keys from secure enclave
        let query = Polish.generateKeyAttributesDictionary()
        let deleteStatus = SecItemDelete(query)
        print("\nAttempted to delete key from secure enclave. Status: \(deleteStatus)\n")
    }
    
    public static func generatePrivateKey() -> SecKey?
    {
        // Generate private key
        var error: Unmanaged<CFError>?
        let attributes = Polish.generateKeyAttributesDictionary()
        
        guard let alicePrivate = SecKeyCreateRandomKey(attributes, &error)
            else
        {
            print("\nUnable to generate the client private key: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return alicePrivate
    }
    
    static func generateKeyAttributesDictionary() -> CFDictionary
    {
        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                     kSecAttrAccessibleAlwaysThisDeviceOnly,
                                                     .privateKeyUsage,
                                                     nil)!
        
        let privateKeyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: Polish.clientTag,
            //kSecAttrAccessControl as String: access
        ]
        
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            //kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: privateKeyAttributes
        ]
        
        return attributes as CFDictionary
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
        guard let encryptedKeyData = encrypt(payload: newKeyData, usingPublicKey: serverKey)
        else
        {
            return nil
        }
        
        return encryptedKeyData
    }
    
    /// Decode data to get public key. This only decodes key data that is NOT padded.
    public static func decodeKey(fromData publicKeyData: Data) -> SecKey?
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
    public func encrypt(payload: Data, usingPublicKey publicKey: SecKey) -> Data?
    {
        var error: Unmanaged<CFError>?
        
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, algorithm, payload as CFData, &error) as Data?
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

