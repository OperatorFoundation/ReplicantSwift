//
//  Encryption.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation
import Security
import CommonCrypto

class Encryption: NSObject
{
    let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM
    //var privateKey: SecKey
    
//    public init?(withPrivateKey initKey: Data?)
//    {
//        if let providedKey = initKey
//        {
//            guard let secKey = Encryption.decodeKey(fromData: providedKey)
//                else
//            {
//                print("\nFailed to initialize Replicant: Unable to create SecKey from key data provided.")
//                return nil
//            }
//
//            privateKey = secKey
//        }
//        else
//        {
//            guard let newKey = Encryption.generatePrivateKey()
//                else
//            {
//                return nil
//            }
//
//            privateKey = newKey
//        }
//
//    }
    
    
    func generatePrivateKey() -> SecKey?
    {
        // Generate private key
        let tag = "com.example.keys.mykey".data(using: .utf8)!
        
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
    
    /**
     Generate a public key from the provided private key and encodes it as data.
     
     - Returns: optional, encoded key as data
     */
    func generatePublicKey(usingPrivateKey privateKey: SecKey) -> Data?
    {
        var error: Unmanaged<CFError>?
        
        guard let alicePublic = SecKeyCopyPublicKey(privateKey)
            else
        {
            print("\nUnable to generate a public key from the provided private key.\n")
            return nil
        }
        
        // Encode public key as data
        guard let alicePublicData = SecKeyCopyExternalRepresentation(alicePublic, &error) as Data?
            else
        {
            print("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        return alicePublicData
    }
    
    /// Decode data to get public key
    static func decodeKey(fromData publicKeyData: Data) -> SecKey?
    {
        var error: Unmanaged<CFError>?
        
        let options: [String: Any] = [kSecAttrKeyType as String: kSecAttrKeyTypeEC,
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
    func encrypt(payload: Data, usingServerKey serverPublicKey: SecKey) -> Data?
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
    func decrypt(payload: Data, usingPrivateKey privateKey: SecKey) -> Data?
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
    
    func cleanKeyData(keyData: Data) -> Data?
    {
        if keyData.count == keyDataSize
        {
            if keyData.first! == 4
            {
                // Strip the redundant 4 from the key data
                let cleanKey = keyData.dropFirst()
                return cleanKey
            }
            else
            {
                print("\nFailed to clean key: Data was 65 bytes but the first byte was not 4.\n")
                return nil
            }
        }
        else if keyData.count == keySize
        {
            print("\nReturning unchanged key data, the byte count was already 64.\n")
            return keyData
        }
        else
        {
            print("Failed to clean key data: unexpected byte count of \(keyData.count)")
            return nil
        }
    }
    
    func getKeyPadding() -> Data?
    {
        var bytes = [UInt8](repeating: 0, count: chunkSize - keySize)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        if status == errSecSuccess
        {
            // Always test the status.
            print(bytes)
            // Prints something different every time you run.
            return Data(array: bytes)
        }
        else
        {
            print("\nFailed to gnerate padding: \(status)\n")
            return nil
        }
    }
    
    func cleanAndPadKey(keyData: Data) -> Data?
    {
        guard let cleanKey = cleanKeyData(keyData: keyData)
        else
        {
            return nil
        }
        
        guard let padding = getKeyPadding()
        else
        {
            return nil
        }
        
        return cleanKey + padding
    }
}
