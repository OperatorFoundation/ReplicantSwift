//
//  ReplicantConfigTemplate.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/14/18.
//

import Foundation
#if os(Linux)
import CryptoKitLinux
#else
import CryptoKit
#endif

public struct ReplicantConfigTemplate
{
    public var polish: PolishClientConfig?
    public var toneBurst: ToneBurstClientConfig?
    
    public init?(polish: PolishClientConfig?, toneBurst: ToneBurstClientConfig?)
    {
        self.polish = polish
        self.toneBurst = toneBurst
    }
    
//    public init?(withConfigAtPath path: String)
//    {
//        guard let config = ReplicantConfigTemplate.parseJSON(atPath: path)
//        else
//        {
//            return nil
//        }
//        
//        self = config
//    }
//    
//    public func createJSON() -> Data?
//    {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        
//        do
//        {
//            let configData = try encoder.encode(self)
//            return configData
//        }
//        catch (let error)
//        {
//            print("Failed to encode config into JSON format: \(error)")
//            return nil
//        }
//    }
//    
//    public static func parseJSON(atPath path: String) -> ReplicantConfigTemplate?
//    {
//        let fileManager = FileManager()
//        let decoder = JSONDecoder()
//        
//        guard let jsonData = fileManager.contents(atPath: path)
//        else
//        {
//            print("\nUnable to get JSON data at path: \(path)\n")
//            return nil
//        }
//        
//        do
//        {
//            let config = try decoder.decode(ReplicantConfigTemplate.self, from: jsonData)
//            return config
//        }
//        catch (let error)
//        {
//            print("\nUnable to decode JSON into ReplicantConfigTemplate: \(error)\n")
//            return nil
//        }
//    }
    
     /// Creates a Replicant client configuration file at the specified path.
    ///
    ///  - Parameters:
    ///      - path: The filepath where the new config file should be saved, this should included the desired file name.
    ///      - serverPublicKey: The public key for the Replicant server. This is required in order for the client to be able to communicate with the server.
    /// - Returns: A boolean indicating whether or not the config was created successfully
//    public func createConfig(atPath path: String, serverPublicKey: P256.KeyAgreement.PublicKey) -> Bool
//    {
//        let fileManager = FileManager()
//
//        // Encode key as data
//        let keyData = serverPublicKey.x963Representation
//
//        guard let replicantConfig = ReplicantConfig(polish: polish, toneBurst: self.toneBurst)
//        else
//        {
//            return false
//        }
//
//        guard let jsonData = replicantConfig.createJSON()
//        else
//        {
//            return false
//        }
//
//        let configCreated = fileManager.createFile(atPath: path, contents: jsonData)
//
//        return configCreated
//    }
}
