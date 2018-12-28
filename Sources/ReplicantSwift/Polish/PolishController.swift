//
//  PolishController.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation

public let keySize = 64
public let aesOverheadSize = 81

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
        var item: CFTypeRef?
        let status = SecItemCopyMatching(generateServerKeySearchQuery(), &item)
        
        switch status
        {
        case errSecItemNotFound:
            // We don't?
            // Let's create some and return those
            return generateKeyPair(withAttributes: generateServerKeyAttributesDictionary())
        case errSecSuccess:
            // Return the pair
            guard let itemDictionary = item as? [String: Any]
            else
            {
                print("Received unexpected key data.")
                return nil
            }
            
            // FIXME: Casting issues here
            let privateKey = itemDictionary[kSecValueRef as String] as! SecKey
            guard let publicKey = generatePublicKey(usingPrivateKey: privateKey)
            else
            {
                print("Unable to generate a public key uding the provided private key.")
                return nil
            }
            
            return (privateKey, publicKey)
            
        default:
            print("\nReceived an unexpacted response while checking for an existing server key: \(status)\n")
            return nil
        }
    }
    
    func deleteKeys()
    {
        //Remove client keys from secure enclave
        let query = generateKeyAttributesDictionary()
        let deleteStatus = SecItemDelete(query)
        print("\nAttempted to delete key from secure enclave. Status: \(deleteStatus)\n")
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
