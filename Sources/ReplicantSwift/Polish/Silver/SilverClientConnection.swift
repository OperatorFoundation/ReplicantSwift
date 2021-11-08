//
//  SilverClientModel.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import Logging
import Transmission
import Net

import Crypto
import Keychain

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
        log = logger
        
        guard let maybeController = SilverController(logger: logger)
        else { return nil }
        controller = maybeController
        
        //TODO: controller.deleteClientKeys()
        
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
    
//    deinit
//    {
//        controller.deleteClientKeys()
//    }
}

public enum PolishError: Error
{
    case noData
    case failedDecrypt
    case writeError
    case readError
}

extension SilverClientConnection: PolishConnection
{
    public func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        log.debug("\n🤝  Client handshake initiation.")
        log.debug("\n🤝  Sending Public Key Data")
        guard let paddedKeyData = controller.generatePaddedKeyData(publicKey: publicKey, chunkSize: chunkSize) else
        {
            completion(PolishError.noData)
            return
        }

        guard connection.write(data: paddedKeyData) else
        {
            self.log.error("\n🤝  Handshake: Returned from sending our public key to the server.\n")
            completion(HandshakeError.writeError)
            return
        }

        let replicantChunkSize = Int(self.chunkSize)
        guard let responseData = connection.read(size: replicantChunkSize) else
        {
            self.log.debug("\n🤝  Callback from handshake network.receive called.")
            completion(HandshakeError.writeError)
            return
        }

        self.log.debug("\n🤝  Received response data from the server during handshake: \(responseData)\n")
        completion(nil)
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
