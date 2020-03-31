//
//  PolishController.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation
import SwiftQueue
import CryptoKit

public struct ChromeController
{
    
    public func generatePrivateKey() -> PrivateEncryptionKey?
    {
        if SecureEnclave.isAvailable
        {
            guard let privateEncryptionKey = try? SecureEnclave.P256.KeyAgreement.PrivateKey() else
            {
                return nil
            }
            
            return .enclave(privateEncryptionKey)
        }
        else
        {
            return .noenclave(P256.KeyAgreement.PrivateKey())
        }
    }
    
    
    
    
    
    
    
    /// MARK: Old Polish Code
    
    
    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
    let polishTag = "org.operatorfoundation.replicant.polish".data(using: .utf8)!
    let polishServerTag = "org.operatorfoundation.replicant.polishServer".data(using: .utf8)!
    
    var logQueue: Queue<String>
    
    public init(logQueue: Queue<String>)
    {
        self.logQueue = logQueue
    }
    
    /// Decode data to get public key. This only decodes key data that is NOT padded.
    public func decodeKey(fromData publicKeyData: Data) -> P256.KeyAgreement.PublicKey?
    {
        // TODO: Use CryptoKit's CompactRepresentation Initializer
        var error: Unmanaged<CFError>?
        
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                      kSecAttrKeySizeInBits as String: 256]
        
        guard let decodedPublicKey = SecKeyCreateWithData(publicKeyData as CFData, options as CFDictionary, &error)
            else
        {
            logQueue.enqueue("\nUnable to decode server public key: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return decodedPublicKey
    }
    
    func fetchOrCreateServerKeyPair() -> PrivateEncryptionKey?
    {
        // Do we already have a key?
        var maybeItem: CFTypeRef?
        let status = SecItemCopyMatching(generateServerKeySearchQuery(), &maybeItem)
        
        switch status
        {
        case errSecItemNotFound:
            // We don't?
            // Let's create some and return those
            return newPrivateEncryptionKey()
        case errSecSuccess:
            guard let item = maybeItem
            else
            {
                logQueue.enqueue("\nKey query returned a nil item.\n")
                return nil
            }
            
            let privateKey = item as! PrivateEncryptionKey
            
            return (privateKey)
            
        default:
            logQueue.enqueue("\nReceived an unexpacted response while checking for an existing server key: \(status)\n")
            return nil
        }
    }
    
    func newPrivateEncryptionKey() -> PrivateEncryptionKey?
    {
        if SecureEnclave.isAvailable
        {
            guard let privateEncryptionKey = try? SecureEnclave.P256.KeyAgreement.PrivateKey() else
            {
                return nil
            }
            
            return .enclave(privateEncryptionKey)
        }
        else
        {
            return .noenclave(P256.KeyAgreement.PrivateKey())
        }
    }
    
    // TODO: Delete Client Keys
    func deleteClientKeys()
    {
//        logQueue.enqueue("\nAttempted to delete key from secure enclave.")
//        //Remove client keys from secure enclave
//        let query: [String: Any] = [kSecClass as String: kSecClassKey,
//                                    kSecAttrApplicationTag as String: polishTag]
//        let deleteStatus = SecItemDelete(query as CFDictionary)
//
//        switch deleteStatus
//        {
//        case errSecItemNotFound:
//            logQueue.enqueue("Could not find a client key to delete.\n")
//        case noErr:
//            logQueue.enqueue("Deleted client keys.\n")
//        default:
//            logQueue.enqueue("Unexpected status: \(deleteStatus.description)\n")
//        }
       
    }
    
//    func generateClientKeyAttributesDictionary() -> CFDictionary
//    {
//        //FIXME: Secure Enclave
//        //let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAlwaysThisDeviceOnly, .privateKeyUsage, nil)!
//
//        let privateKeyAttributes: [String: Any] = [
//            kSecAttrIsPermanent as String: true,
//            kSecAttrApplicationTag as String: polishTag
//            //kSecAttrAccessControl as String: access
//        ]
//
//        let publicKeyAttributes: [String: Any] = [
//            kSecAttrIsPermanent as String: true,
//            kSecAttrApplicationTag as String: polishTag
//        ]
//
//        let attributes: [String: Any] = [
//            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
//            kSecAttrKeySizeInBits as String: 256,
//            //kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
//            kSecPrivateKeyAttrs as String: privateKeyAttributes,
//            kSecPublicKeyAttrs as String: publicKeyAttributes
//        ]
//
//        return attributes as CFDictionary
//    }
    
//    func generateServerKeyAttributesDictionary() -> CFDictionary
//    {
//        //FIXME: Secure Enclave
//        // let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAlwaysThisDeviceOnly, .privateKeyUsage, nil)!
//
//        let privateKeyAttributes: [String: Any] = [
//            kSecAttrIsPermanent as String: true,
//            kSecAttrApplicationTag as String: polishServerTag
//            //kSecAttrAccessControl as String: access
//        ]
//
//        let publicKeyAttributes: [String: Any] = [
//            kSecAttrIsPermanent as String: true,
//            kSecAttrApplicationTag as String: polishServerTag
//        ]
//
//        let attributes: [String: Any] = [
//            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
//            kSecAttrKeySizeInBits as String: 256,
//            //kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
//            kSecPrivateKeyAttrs as String: privateKeyAttributes,
//            kSecPublicKeyAttrs as String: publicKeyAttributes
//        ]
//
//        return attributes as CFDictionary
//    }
    
    func generateServerKeySearchQuery() -> CFDictionary
    {
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: polishServerTag,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnRef as String: true,
                                    kSecReturnAttributes as String: false,
                                    kSecReturnData as String: false]
        
        return query as CFDictionary
    }
    
    /// This is the format needed to send the key to the server.
    public func generateAndEncryptPaddedKeyData(fromKey key: SecKey, withChunkSize chunkSize: UInt16, usingServerKey serverKey: SecKey) -> Data?
    {
        var error: Unmanaged<CFError>?
        var newKeyData: Data

        // Encode key as data
        guard let keyData = SecKeyCopyExternalRepresentation(key, &error) as Data?
            else
        {
            logQueue.enqueue("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }

        newKeyData = keyData
        keySize = newKeyData.count
        
        // Add padding if needed
        if let padding = getKeyPadding(chunkSize: chunkSize, keySize: keySize)
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
    
    //MARK: Encryption
    
    /// Encrypt payload
    public func encrypt(payload: Data, usingPublicKey publicKey: SecKey) -> Data?
    {
        var error: Unmanaged<CFError>?
        
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, algorithm, payload as CFData, &error) as Data?
            else
        {
            logQueue.enqueue("\nUnable to encrypt payload: \(error!.takeRetainedValue() as Error)\n")
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
        
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algorithm)
            else
        {
            print("Private key does not support \(algorithm) algorithm for decryption.")
            return nil
        }
        
        guard let decryptedText = SecKeyCreateDecryptedData(privateKey, algorithm, payload as CFData, &error) as Data?
            else
        {
            logQueue.enqueue("\nUnable to decrypt payload: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return decryptedText
    }
    
    func getKeyPadding(chunkSize: UInt16, keySize: Int) -> Data?
    {
        let paddingSize = Int(chunkSize) - (keySize + aesOverheadSize)
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

public enum PrivateEncryptionKey
{
    case enclave(SecureEnclave.P256.KeyAgreement.PrivateKey)
    case noenclave(P256.KeyAgreement.PrivateKey)
    
    var publicKey: P256.KeyAgreement.PublicKey
    {
        get
        {
            switch(self)
            {
                case .enclave(let privateKey):
                    return privateKey.publicKey
                case .noenclave(let privateKey):
                    return privateKey.publicKey
            }
        }
    }
    
    func sharedSecretFromKeyAgreement(with publicEncryptionKey: P256.KeyAgreement.PublicKey) throws -> SharedSecret
    {
        switch(self)
        {
            case .enclave(let privateKey):
                return try privateKey.sharedSecretFromKeyAgreement(with: publicEncryptionKey)
            case .noenclave(let privateKey):
                return try privateKey.sharedSecretFromKeyAgreement(with: publicEncryptionKey)
        }
    }
}
