//
//  ReplicantConfigTemplate.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/14/18.
//

import Foundation

import Crypto

public struct ReplicantConfigTemplate: Codable
{
    var maybePolishClientConfig: PolishClientConfig?
    var maybeToneBurstClientConfig: ToneBurstClientConfig?
//    // Polish Properties
//    var chunkSize: UInt16?
//    var chunkTimeout: Int?
//    var polishType: PolishType?
    
    
    public init(polishClientConfig: PolishClientConfig?, toneBurstConfig: ToneBurstClientConfig?)
    {
        self.maybePolishClientConfig = polishClientConfig
        self.maybeToneBurstClientConfig = toneBurstConfig
    }
    
    public init?(withConfigAtPath path: String)
    {
        guard let config = ReplicantConfigTemplate.parseJSON(atPath: path)
        else
        {
            return nil
        }
        
        self = config
    }
    
    public func createJSON() -> Data?
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do
        {
            let configData = try encoder.encode(self)
            return configData
        }
        catch (let error)
        {
            print("Failed to encode config into JSON format: \(error)")
            return nil
        }
    }
    
    public static func parseJSON(atPath path: String) -> ReplicantConfigTemplate?
    {
        let fileManager = FileManager()
        let decoder = JSONDecoder()
        
        guard let jsonData = fileManager.contents(atPath: path)
        else
        {
            print("\nUnable to get JSON data at path: \(path)\n")
            return nil
        }
        
        do
        {
            let config = try decoder.decode(ReplicantConfigTemplate.self, from: jsonData)
            return config
        }
        catch (let error)
        {
            print("\nUnable to decode JSON into ReplicantConfigTemplate: \(error)\n")
            return nil
        }
    }
    
    /// Creates a Replicant client configuration file at the specified path.
    ///  - Parameters:
    ///      - path: The filepath as a String, where the new config file should be saved, this should included the desired file name.
    ///      - serverIP: The IP address of the Replicant Server as a String.
    ///      - port: The port the provided server will be listening on for Replicant traffic as a UInt16
    ///      - serverPublicKey: The public key for the Replicant server. This is required in order for the client to be able to communicate with the server.
    /// - Returns: A boolean indicating whether or not the config was created successfully
    public func createClientConfig(atPath path: String, serverIP: String, port: UInt16) -> Bool
    {
        let fileManager = FileManager.default
        
        guard let replicantConfig = ReplicantConfig(serverIP: serverIP, port: port, polish: self.maybePolishClientConfig, toneBurst: self.maybeToneBurstClientConfig)
        else
        {
            return false
        }

       guard let jsonData = replicantConfig.createJSON()
       else
       {
           return false
       }

       let configCreated = fileManager.createFile(atPath: path, contents: jsonData)
        
        if configCreated
        {
            print("Created a Replicant client config at \(path):\n\(jsonData)")
        }

       return configCreated
    }

    
    public func printTemplateJSON()
    {
        guard let jsonData = createJSON()
        else
        {
            print("There was an error printing this template: we were unable to encode it to JSON format")
            return
        }
        
        print(jsonData)
    }
}
