//
//  DarkStarClientConnection.swift
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

public class DarkStarPolishClientConnection: Polish
{
    public let controller: DarkStarPolishController
    public var serverPublicKey: P256.KeyAgreement.PublicKey
    public var publicKey: P256.KeyAgreement.PublicKey
    public var privateKey: P256.KeyAgreement.PrivateKey
    public var symmetricKey: SymmetricKey
    public var chunkSize: UInt16
    public var chunkTimeout: Int

    public let log: Logger
    
    public init?(logger: Logger, serverPublicKeyData: Data, chunkSize: UInt16, chunkTimeout: Int)
    {
        log = logger
        
        guard let maybeController = DarkStarPolishController(logger: logger)
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
}

public enum DarkStarError: Error
{
    case noData
    case failedDecrypt
    case writeError
    case readError
}

extension DarkStarPolishClientConnection: PolishConnection
{
    public func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        // FIXME
        return
    }
    
    public func polish(inputData: Data) -> Data?
    {
        // FIXME
        return nil
    }
    
    public func unpolish(polishedData: Data) -> Data?
    {
        //FIXME
        return nil
    }
}


