//
//  SilverClientModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import Logging
import Transport

#if (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
import CryptoKit
#else
import Crypto
#endif

#if os(Linux)
import NetworkLinux
//import CryptoKitLinux
#else
import Network
//import CryptoKit
#endif

public class SilverClientConnection
{
    public let controller: SilverController
    public var serverPublicKey: P256.KeyAgreement.PublicKey
    public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    public var symmetricKey: SymmetricKey
    public var chunkSize: UInt16
    public var chunkTimeout: Int

    let log: Logger
    
    public init?(logger: Logger, serverPublicKeyData: Data, chunkSize: UInt16, chunkTimeout: Int)
    {
        self.log = logger
        self.controller = SilverController(logger: logger)
        controller.deleteClientKeys()
        
        guard let sPublicKey = controller.decodeKey(fromData: serverPublicKeyData)
        else
        {
            return nil
        }

        let clientPrivateKey = P256.KeyAgreement.PrivateKey()
        let clientPublicKey = clientPrivateKey.publicKey
        
        self.serverPublicKey = sPublicKey
        self.privateKey = clientPrivateKey
        self.publicKey = clientPublicKey
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        
        guard let ourSymmetricKey = controller.deriveSymmetricKey(receiverPublicKey: serverPublicKey, senderPrivateKey: privateKey)
            else { return nil }
        
        self.symmetricKey = ourSymmetricKey
    }
    
    deinit
    {
        controller.deleteClientKeys()
    }
}

extension SilverClientConnection: PolishConnection
{
    public func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        log.debug("\n🤝  Client handshake initiation.")
        log.debug("\n🤝  Sending Public Key Data")
        let paddedKeyData = controller.generatePaddedKeyData(publicKey: publicKey, chunkSize: chunkSize)
        connection.send(content: paddedKeyData, contentContext: .defaultMessage, isComplete: false, completion: NWConnection.SendCompletion.contentProcessed(
        {
            (maybeError) in
            
            self.log.error("\n🤝  Handshake: Returned from sending our public key to the server.\n")
            guard maybeError == nil
                else
            {
                self.log.error("\n🤝  Received error from server when sending our key: \(maybeError!)")
                completion(maybeError!)
                return
            }
            
            let replicantChunkSize = Int(self.chunkSize)
            connection.receive(minimumIncompleteLength: replicantChunkSize, maximumLength: replicantChunkSize, completion:
            {
                (maybeResponse1Data, maybeResponse1Context, _, maybeResponse1Error) in
                
                self.log.debug("\n🤝  Callback from handshake network.receive called.")
                guard maybeResponse1Error == nil
                    else
                {
                    self.log.error("\n🤝  Received an error while waiting for response from server after sending key: \(maybeResponse1Error!)")
                    completion(maybeResponse1Error!)
                    return
                }
                
                // This data is meaningless it can be discarded
                guard let reponseData = maybeResponse1Data
                    else
                {
                    self.log.error("\n🤝  Server key response did not contain data.")
                    completion(nil)
                    return
                }
                
                self.log.debug("\n🤝  Received response data from the server during handshake: \(reponseData)\n")
                completion(nil)
            })
        }))
    }
    
    public func polish(inputData: Data) -> Data?
    {
        guard let sealedBox = controller.encrypt(payload: inputData, symmetricKey: symmetricKey)
            else { return nil }
        
        return sealedBox.combined
    }
    
    public func unpolish(polishedData: Data) -> Data? {
        do
        {
            guard let unpolished = try controller.decrypt(payload: ChaChaPoly.SealedBox(combined: polishedData), symmetricKey: symmetricKey)
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
