//
//  ReplicantConfigTemplate.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/14/18.
//

import Foundation

public struct ReplicantConfigTemplate: Codable
{
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    public var addSequences: [SequenceModel]?
    public var removeSequences: [SequenceModel]?
    
    
    public init?(chunkSize: UInt16, chunkTimeout: Int, addSequences: [SequenceModel]?, removeSequences: [SequenceModel]?)
    {
        guard chunkSize >= keySize + aesOverheadSize
            else
        {
            print("\nUnable to initialize ReplicantConfig: chunkSize (\(chunkSize)) cannot be smaller than keySize + aesOverheadSize (\(keySize + aesOverheadSize))\n")
            return nil
        }
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        self.addSequences = addSequences
        self.removeSequences = removeSequences
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
    
    static public func parseJSON(atPath path: String) -> ReplicantConfigTemplate?
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
    ///
    ///  - Parameters:
    ///      - path: The filepath where the new config file should be saved, this should included the desired file name.
    ///      - serverPublicKey: The public key for the Replicant server. This is required in order for the client to be able to communicate with the server.
    /// - Returns: A boolean indicating whether or not the config was created successfully
    public func createConfig(atPath path: String, withServerKey serverPublicKey: SecKey) -> Bool
    {
        let fileManager = FileManager()
        var error: Unmanaged<CFError>?
        
        // Encode key as data
        guard let keyData = SecKeyCopyExternalRepresentation(serverPublicKey, &error) as Data?
            else
        {
            print("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
            return false
        }
        
        guard let replicantConfig = ReplicantConfig(serverPublicKey: keyData, chunkSize: self.chunkSize, chunkTimeout: self.chunkTimeout, addSequences: self.addSequences, removeSequences: self.removeSequences)
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
        
        return configCreated
    }
}
