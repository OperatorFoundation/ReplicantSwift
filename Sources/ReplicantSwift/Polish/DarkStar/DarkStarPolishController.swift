//
//  DarkStarController.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Crypto
import Foundation
import Logging

import Keychain

public struct DarkStarPolishController
{
    let serverKeyLabel = "ServerKey"
    
    let compactKeySize = 32
    let log: Logger
    var keychain: Keychain
        
    public init?(logger: Logger)
    {
        self.log = logger
        
        #if (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
        keychain = Keychain()
        #else
        guard let linuxKeychain = Keychain(baseDirectory: FileManager.default.homeDirectoryForCurrentUser)
        else { return nil }
        keychain = linuxKeychain
        #endif
    }
    
    /// Decode data to get public key. This only decodes key data that is NOT padded.
    public func decodeKey(fromData publicKeyData: Data) -> P256.KeyAgreement.PublicKey?
    {
        return try? P256.KeyAgreement.PublicKey(compactRepresentation: publicKeyData)
    }
    
    public func deriveSymmetricKey(receiverPublicKey: P256.KeyAgreement.PublicKey, senderPrivateKey:P256.KeyAgreement.PrivateKey) -> SymmetricKey?
    {
        do
        {
            let sharedSecret = try senderPrivateKey.sharedSecretFromKeyAgreement(with: receiverPublicKey)
            let symmetricKey = sharedSecret.x963DerivedSymmetricKey(using: SHA256.self, sharedInfo: Data(), outputByteCount: 32)
            
            return symmetricKey
        }
        catch let sharedSecretError
        {
            print("Unable to encrypt payload. Failed to generate a shared secret: \(sharedSecretError)")
            return nil
        }
    }
    
    func fetchOrCreateServerKey() -> P256.KeyAgreement.PrivateKey?
    {
        return keychain.retrieveOrGeneratePrivateKey(label: serverKeyLabel)
    }
    
    public func fetchServerPublicKey() -> P256.KeyAgreement.PublicKey?
    {
        guard let privateKey = keychain.retrievePrivateKey(label: serverKeyLabel)
        else
        {
            print("Failed to retrieve server key.")
            return nil
        }
        
        return privateKey.publicKey
    }
    
    /// This is the format needed to send the key to the server.
    public func generatePaddedKeyData(publicKey: P256.KeyAgreement.PublicKey, chunkSize: UInt16) -> Data?
    {
        // Encode key as data
        guard var newKeyData = publicKey.compactRepresentation
        else
        {
            print("Failed to create compact representation of key for padded key data request.")
            return nil
        }
        
        let keySize = newKeyData.count

        // Add padding if needed
        if let padding = getKeyPadding(chunkSize: chunkSize, keySize: keySize)
        {
            newKeyData += padding
        }

        return newKeyData
    }
    
    //MARK: Encryption
    
    /// Encrypt payload
    public func encrypt(payload: Data, symmetricKey: SymmetricKey) -> ChaChaPoly.SealedBox?
    {
        do
        {
            let cipherText = try ChaChaPoly.seal(payload, using: symmetricKey)
            return cipherText
        }
        catch let cipherError
        {
            print("Error encrypting payload: \(cipherError)")
            return nil
        }
    }
    
    /// Decrypt payload
    /// - Parameter payload: Data
    /// - Parameter symmetricKey: SymmetricKey
    public func decrypt(payload: ChaChaPoly.SealedBox, symmetricKey: SymmetricKey) -> Data?
    {
        do
        {
            let decryptedMessage = try ChaChaPoly.open(payload, using: symmetricKey)
            return decryptedMessage
        }
        catch let decryptionError
        {
            print("Error decrypting payload: \(decryptionError)")
        }

        return nil
    }
    
    func getKeyPadding(chunkSize: UInt16, keySize: Int) -> Data?
    {
        // FIXME: Removed aesOverheadsize
        // let paddingSize = Int(chunkSize) - (keySize + aesOverheadSize)
        let paddingSize = Int(chunkSize) - keySize
        if paddingSize > 0
        {
            // FIXME: Should we generate random data here?
            // Replaced:
            // let bytes = [UInt8](repeating: 0, count: paddingSize)
            let randomData = generateRandomBytes(count: paddingSize)
            return randomData
        }
        else
        {
            return nil
        }
    }
    
}
