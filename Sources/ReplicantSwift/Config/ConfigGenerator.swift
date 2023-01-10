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
    
    guard let newConfigs = generateNewConfigPair(serverAddress: serverAddress, polish: polish, toneburst: toneburst) else
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

public func generateNewConfigPair(serverAddress: String, polish: Bool, toneburst: Bool) -> (serverConfig: ReplicantServerConfig, clientConfig: ReplicantClientConfig)?{
    var toneburstClientConfig: ToneBurstClientConfig? = nil
    var toneburstServerConfig: ToneBurstServerConfig? = nil
    var polishClientConfig: PolishClientConfig? = nil
    var polishServerConfig: PolishServerConfig? = nil
    
    if toneburst {
        let starburstServer = StarburstConfig(mode: StarburstMode.SMTPServer)
        let starburstClient = StarburstConfig(mode: StarburstMode.SMTPClient)
        toneburstClientConfig = ToneBurstClientConfig.starburst(config: starburstClient)
        toneburstServerConfig = ToneBurstServerConfig.starburst(config: starburstServer)
    }
    if polish {
        let privateKey = PrivateKey.P256KeyAgreement(P256.KeyAgreement.PrivateKey())
        let publicKey = privateKey.publicKey
        polishClientConfig = PolishClientConfig(serverAddress: serverAddress, serverPublicKey: publicKey)
        polishServerConfig = PolishServerConfig(serverAddress: serverAddress, serverPrivateKey: privateKey)
    }
    
    let clientConfig = ReplicantClientConfig(serverAddress: "<serverAddress>", polish: polishClientConfig, toneBurst: toneburstClientConfig, transport: "Replicant")
    let serverConfig = ReplicantServerConfig(serverAddress: "<serverAddress>", polish: polishServerConfig, toneBurst: toneburstServerConfig, transport: "Replicant")
    
    return (serverConfig, clientConfig)
}
