//
//  SilverServerConnection.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import Logging
import Network
import CryptoKit
import Transport

public class SilverServerConnection
{
    public let controller: SilverController
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    public var symmetricKey: SymmetricKey?

    let log: Logger
    
    public init?(logger: Logger, chunkSize: UInt16, chunkTimeout: Int)
    {
        self.log = logger
        self.controller = SilverController(logger: logger)
        controller.deleteClientKeys()

        let clientPrivateKey = P256.KeyAgreement.PrivateKey()
        let clientPublicKey = clientPrivateKey.publicKey
        
        self.privateKey = clientPrivateKey
        self.publicKey = clientPublicKey
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
    }
    
    deinit
    {
        controller.deleteClientKeys()
    }
}

extension SilverServerConnection: PolishConnection
{
    public func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        print("\n🤝  Replicant Server handshake called.")
        let replicantChunkSize = chunkSize
        
        //Call receive first
        connection.receive(minimumIncompleteLength: Int(replicantChunkSize), maximumLength: Int(replicantChunkSize))
        {
            (maybeResponse1Data, maybeResponse1Context, _, maybeResponse1Error) in
            
            print("\n🤝  network.receive callback from handshake.")
            print("\n🤝  Data received: \(String(describing: maybeResponse1Data?.bytes))")
            
            // Parse received public key and store it
            guard maybeResponse1Error == nil
            else
            {
                print("\n\n🤝  Received an error while waiting for response from server acfter sending key: \(maybeResponse1Error!)\n")
                completion(maybeResponse1Error!)
                return
            }
            
            // Make sure we have data
            guard let clientPaddedData = maybeResponse1Data
            else
            {
                print("\nClient introduction did not contain data.\n")
                completion(HandshakeError.noClientKeyData)
                return
            }
            
            // Key data is the first chunk of keyDataSize
            let clientKeyData = clientPaddedData[..<self.controller.compactKeySize]

                
            // Convert data to SecKey
            //FIXME: Will decode key method account for leading 04?
            guard let clientKey = self.controller.decodeKey(fromData: clientKeyData)
            else
            {
                print("\nUnable to decode client key.\n")
                completion(HandshakeError.invalidClientKeyData)
                return
            }
            
            let derivedKey = self.controller.deriveSymmetricKey(receiverPublicKey: clientKey, senderPrivateKey: self.privateKey)
            self.symmetricKey = derivedKey
            
            let configChunkSize = Int(self.chunkSize)
            
            //Generate random data of chunk size
            guard let randomData = generateRandomBytes(count: configChunkSize)
            else
            {
                completion(HandshakeError.dataCreationError)
                return
            }
            
            //Send random data to client
            connection.send(content: randomData, contentContext: .defaultMessage, isComplete: false, completion: NWConnection.SendCompletion.contentProcessed(
            {
                (maybeError) in
                
                guard maybeError == nil
                    else
                {
                    print("\nReceived error from client when sending random data in handshake: \(maybeError!)")
                    completion(maybeError!)
                    return
                }
            }))
        }

    }
    
    public func polish(inputData: Data) -> Data?
    {
        guard let derivedKey = symmetricKey
            else { return nil }
        guard let sealedBox = controller.encrypt(payload: inputData, symmetricKey: derivedKey)
            else { return nil }
        
        return sealedBox.combined
    }
    
    public func unpolish(polishedData: Data) -> Data?
    {
        guard let derivedKey = symmetricKey
        else { return nil }
        
        do
        {
            guard let unpolished = try controller.decrypt(payload: ChaChaPoly.SealedBox(combined: polishedData), symmetricKey: derivedKey)
            else
            {
                print("Unpolish returned nil.")
                return nil
            }
            
            return unpolished
        }
        catch let error
        {
            print("Received an error when attempting to decrypt data: \(error)")
            return nil
        }
    }
    
}
