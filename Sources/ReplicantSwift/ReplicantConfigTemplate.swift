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
    // TODO: Toneburst Properties
    var toneBurstType: ToneBurstType?
    var addSequences: [SequenceModel]?
    var removeSequences: [SequenceModel]?
    
    // Polish Properties
    var chunkSize: UInt16?
    var chunkTimeout: Int?
    var polishType: PolishType?
    
    
    public init(chunkSize: UInt16?, chunkTimeout: Int?, polishType: PolishType?, toneBurstType: ToneBurstType?)
    {
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        self.polishType = polishType
        self.toneBurstType = toneBurstType
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
    public func createClientConfig(atPath path: String, serverIP: String, port: UInt16, serverPublicKey: String) -> Bool
    {
        let fileManager = FileManager.default

       // Encode key as data
        guard let keyData = serverPublicKey.data(using: .utf8) else
        {
            print("Failed to load the provided key String as Data.")
            return false
        }
        
        
        // Polish Config
        var maybePolishConfig: PolishClientConfig?
        
        if self.chunkSize != nil && self.chunkTimeout != nil
        {
            switch polishType
            {
                case .silver:
                    maybePolishConfig = PolishClientConfig.silver(serverPublicKeyData: keyData, chunkSize: self.chunkSize!, chunkTimeout: self.chunkTimeout!)
                case .none:
                    break
            }
        }

        // ToneBurst Config
        var maybeToneBurstConfig: ToneBurstClientConfig?
        
        if self.addSequences != nil && self.removeSequences != nil
        {
            switch toneBurstType
            {
                case .whalesong:
                    if let whalesongClient = WhalesongClient(addSequences: self.addSequences!, removeSequences: self.removeSequences!)
                    {
                        maybeToneBurstConfig = ToneBurstClientConfig.whalesong(client: whalesongClient)
                    }
                    
                case .none:
                    break
            }
        }
        
        guard let replicantConfig = ReplicantConfig(serverIP: serverIP, port: port, polish: maybePolishConfig, toneBurst: maybeToneBurstConfig)
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
