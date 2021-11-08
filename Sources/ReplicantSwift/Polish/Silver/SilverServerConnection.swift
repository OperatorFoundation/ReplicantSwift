//
//  SilverServerConnection.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import Logging
import Transmission
import Net

import Crypto

public class SilverServerConnection
{
    public let controller: SilverController
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    //public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    public var symmetricKey: SymmetricKey?

    let log: Logger
    
    public init?(logger: Logger, chunkSize: UInt16, chunkTimeout: Int)
    {
        self.log = logger
        guard let maybeController = SilverController(logger: logger)
        else { return nil }
        self.controller = maybeController
        
        // Check to see if the server already has a keypair first
        // If not, create one and save it.
        guard let serverPrivateKey = controller.fetchOrCreateServerKey()
            else
        {
            return nil
        }
        
        self.privateKey = serverPrivateKey
        //self.publicKey = clientPublicKey
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
    }
}

extension SilverServerConnection: PolishConnection
{
    public func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        print("\n🤝  Replicant Server handshake called.")
        let replicantChunkSize = chunkSize
        
        //Call read first
        guard let clientPaddedData = connection.read(size: Int(replicantChunkSize)) else
        {
            print("\n\n🤝  Received an error while waiting for response from server acfter sending key\n")
            completion(HandshakeError.noClientKeyData)
            return
        }

        print("\n🤝  Data received: \(String(describing: clientPaddedData.bytes))")

        // Key data is the first chunk of keyDataSize
        let clientKeyData = clientPaddedData[..<self.controller.compactKeySize]

        // Convert data to Key
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
        let randomData = generateRandomBytes(count: configChunkSize)

        guard connection.write(data: randomData) else
        {
            completion(HandshakeError.writeError)
            return
        }

        completion(nil)
        return
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
