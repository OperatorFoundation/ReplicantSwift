//
//  ConfigGenerator.swift
//  
//
//  Created by Joshua Clark on 12/19/22.
//

import Crypto
import Foundation

import Gardener
import KeychainTypes
import ShadowSwift

public func createNewConfigFiles(inDirectory saveDirectory: URL, serverAddress: String, polish: Bool, toneburst: Bool)  -> Bool
{
    guard saveDirectory.isDirectory else
    {
        print("The provided destination is not a directory: \(saveDirectory.path)")
        return false
    }
    
    guard let newConfigs = generateNewConfigPair(serverAddress: serverAddress, usePolish: polish, useToneburst: toneburst) else
    {
        return false
    }
    
    guard let clientJson = newConfigs.clientConfig.createJSON() else {
        return false
    }
    
    guard let serverJson = newConfigs.serverConfig.createJSON() else {
        return false
    }
    
    let serverConfigFilename = "ReplicantServerConfig.json"
    let serverConfigFilePath = saveDirectory.appendingPathComponent(serverConfigFilename).path
    
    guard File.put(serverConfigFilePath, contents: serverJson) else
    {
        return false
    }
    
    let clientConfigFilename = "ReplicantClientConfig.json"
    let clientConfigFilePath = saveDirectory.appendingPathComponent(clientConfigFilename).path
    
    guard File.put(clientConfigFilePath, contents: clientJson) else
    {
        return false
    }
        
    return true
}

public func generateNewConfigPair(serverAddress: String, usePolish: Bool, useToneburst: Bool) -> (serverConfig: ReplicantServerConfig, clientConfig: ReplicantClientConfig)?
{
    var toneBurstClient: ToneBurst? = nil
    var toneBurstServer: ToneBurst? = nil
    var polishClientConfig: PolishClientConfig? = nil
    var polishServerConfig: PolishServerConfig? = nil
    
    if useToneburst {
        toneBurstClient = Starburst(.SMTPClient)
        toneBurstServer = Starburst(.SMTPServer)
    }
    
    if usePolish {
        let compactRepresentable = P256.KeyAgreement.PrivateKey(compactRepresentable: true)
        print("raw representation: \(compactRepresentable.rawRepresentation.hex) (count: \(compactRepresentable.rawRepresentation.count)) | x963 representation: \(compactRepresentable.x963Representation.hex) (count: \(compactRepresentable.x963Representation.count)")
        let privateKey = PrivateKey.P256KeyAgreement(compactRepresentable)
        
        let publicKey = privateKey.publicKey
        polishClientConfig = PolishClientConfig(serverAddress: serverAddress, serverPublicKey: publicKey)
        polishServerConfig = PolishServerConfig(serverAddress: serverAddress, serverPrivateKey: privateKey)
    }
    
    guard let clientConfig = ReplicantClientConfig(serverAddress: serverAddress, polish: polishClientConfig, toneBurst: toneBurstClient, transport: "Replicant") else
    {
        return nil
    }
    
    let serverConfig = ReplicantServerConfig(serverAddress: serverAddress, polish: polishServerConfig, toneBurst: toneBurstServer, transport: "Replicant")
    
    return (serverConfig, clientConfig)
}
