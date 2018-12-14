//
//  ReplicantConfigTemplate.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/14/18.
//

import Foundation

public struct ReplicantConfigTemplate: Codable
{
    public var chunkSize: Int
    public var chunkTimeout: Int
    public var addSequences: [SequenceModel]?
    public var removeSequences: [SequenceModel]?
    
    
    public init?(chunkSize: Int, chunkTimeout: Int, addSequences: [SequenceModel]?, removeSequences: [SequenceModel]?)
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
    
    public func createJSON() -> String?
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do
        {
            let configData = try encoder.encode(self)
            return String(data: configData, encoding: .utf8)
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
    
    public func createConfig(withServerKey serverPublicKey: SecKey) -> String?
    {
        // Encode key as data
        var error: Unmanaged<CFError>?
        
        guard let keyData = SecKeyCopyExternalRepresentation(serverPublicKey, &error) as Data?
            else
        {
            print("\nUnable to generate public key external representation: \(error!.takeRetainedValue() as Error)\n")
            return nil
        }
        
        guard let replicantConfig = ReplicantConfig(serverPublicKey: keyData, chunkSize: self.chunkSize, chunkTimeout: self.chunkTimeout, addSequences: self.addSequences, removeSequences: self.removeSequences)
        else
        {
            return nil
        }
        
        return replicantConfig.createJSON()
    }
}
