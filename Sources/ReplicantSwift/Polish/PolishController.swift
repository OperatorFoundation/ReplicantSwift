//
//  PolishController.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation

public let aesOverheadSize = 113
public var keySize = 65

public struct PolishController
{
    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorVariableIVX963SHA256AESGCM
    let polishTag = "org.operatorfoundation.replicant.polish".data(using: .utf8)!
    let polishServerTag = "org.operatorfoundation.replicant.polishServer".data(using: .utf8)!
    
    /// Decode data to get public key. This only decodes key data that is NOT padded.
    public func decodeKey(fromData publicKeyData: Data) -> SecKey?
    {
        var error: Unmanaged<CFError>?
        
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                                      kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                                      kSecAttrKeySizeInBits as String: 256]
        
        guard let decodedPublicKey = SecKeyCreateWithData(publicKeyData as CFData, options as CFDictionary, &error)
            else
        {
            print("\nUnable to decode server public key: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return decodedPublicKey
    }
    
    /// This doesn't work with a key returned from the keychain.
    /// Use generate with data instead.
    public func generatePrivateKey(withAttributes attributes: CFDictionary) -> SecKey?
    {
        // Generate private key
        var error: Unmanaged<CFError>?
        //let attributes = self.generateKeyAttributesDictionary()
        
        guard let privateKey = SecKeyCreateRandomKey(attributes, &error)
            else
        {
            print("\nUnable to generate the client private key: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return privateKey
    }
    
    /// This doesn't work with a key returned from the keychain.
    /// Use generate with data instead.
    func generatePublicKey(usingPrivateKey privateKey: SecKey) -> SecKey?
    {
        guard let publicKey = SecKeyCopyPublicKey(privateKey)
            else
        {
            print("\nUnable to generate a public key from the provided private key.\n")
            return nil
        }
        
        return publicKey
    }
    
    func generatePublicKey(usingPrivateKeyData privateKeyData: Data) -> SecKey?
    {
        var error: Unmanaged<CFError>?
        let attributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom, kSecAttrKeyClass: kSecAttrKeyClassPrivate]
        
        guard let publicKey = SecKeyCreateWithData(privateKeyData as CFData, attributes as CFDictionary, &error)
            else
        {
            print("\nUnable to generate a public key from the provided private key.\(String(describing: error))\n")
            return nil
        }
        
        return publicKey
    }
    
    func generateKeyPair(withAttributes attributes: CFDictionary) -> (privateKey: SecKey, publicKey: SecKey)?
    {
        guard let privateKey = generatePrivateKey(withAttributes: attributes)
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
    
    func fetchOrCreateServerKeyPair() ->(privateKey: SecKey, publicKey: SecKey)?
    {
        
        // Do we already have a key?
        var maybeItem: CFTypeRef?
        let status = SecItemCopyMatching(generateServerKeySearchQuery(), &maybeItem)
        
        switch status
        {
        case errSecItemNotFound:
            // We don't?
            // Let's create some and return those
            return generateKeyPair(withAttributes: generateServerKeyAttributesDictionary())
        case errSecSuccess:
            guard let item = maybeItem
            else
            {
                print("\nKey query returned a nil item.\n")
                return nil
            }
            
            let privateKey = item as! SecKey
            
            // This is weirdly broken so we have to use data instead
//            guard let publicKey = generatePublicKey(usingPrivateKey: privateKey)
//            else
//            {
//                print("Unable to generate a public key uding the provided private key.")
//                return nil
//            }
            
            var error: Unmanaged<CFError>?
            var newKeyData: Data
            
            // Encode key as data
            guard let keyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data?
                else
            {
                print("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
                return nil
            }
            
            newKeyData = keyData
            
            guard let publicKey = generatePublicKey(usingPrivateKeyData: newKeyData)
                else
            {
                print("Unable to generate a public key using the provided private key data.")
                return nil
            }
            
            return (privateKey, publicKey)
            
        default:
            print("\nReceived an unexpacted response while checking for an existing server key: \(status)\n")
            return nil
        }
    }
    
    func deleteClientKeys()
    {
        print("\nAttempted to delete key from secure enclave.")
        //Remove client keys from secure enclave
        let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                    kSecAttrApplicationTag as String: polishTag]
        let deleteStatus = SecItemDelete(query as CFDictionary)
        
        switch deleteStatus
        {
        case errSecItemNotFound:
            print("Could not find a client key to delete.\n")
        case noErr:
            print("Deleted client keys.\n")
        default:
            print("Unexpected status: \(deleteStatus.description)\n")
        }
       
    }
    
    func generateKeyAttributesDictionary() -> CFDictionary
    {
        //FIXME: Secure Enclave
        //let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAlwaysThisDeviceOnly, .privateKeyUsage, nil)!
        
        let privateKeyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: polishTag,
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
    
    func generateServerKeyAttributesDictionary() -> CFDictionary
    {
        //FIXME: Secure Enclave
        // let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAlwaysThisDeviceOnly, .privateKeyUsage, nil)!
        
        let privateKeyAttributes: [String: Any] = [
            kSecAttrIsPermanent as String: true,
            kSecAttrApplicationTag as String: polishServerTag,
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
            print("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
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
