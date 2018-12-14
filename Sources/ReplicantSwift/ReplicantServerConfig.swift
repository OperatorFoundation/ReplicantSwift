//
//  ReplicantServerConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/7/18.
//

import Foundation

public struct ReplicantServerConfig: Codable
{
    public var chunkSize: Int
    public var chunkTimeout: Int
    public var addSequences: [SequenceModel]?
    public var removeSequences: [SequenceModel]?
    
    public init?(serverPublicKey: SecKey, chunkSize: Int, chunkTimeout: Int, addSequences: [SequenceModel]?, removeSequences: [SequenceModel]?)
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
            let serverConfigData = try encoder.encode(self)
            return String(data: serverConfigData, encoding: .utf8)
        }
        catch (let error)
        {
            print("Failed to encode Server config into JSON format: \(error)")
            return nil
        }
    }
    
    static public func parseJSON(jsonString: String) -> ReplicantServerConfig?
    {
        let decoder = JSONDecoder()
        let jsonData = jsonString.data
        
        do
        {
            let config = try decoder.decode(ReplicantServerConfig.self, from: jsonData)
            return config
        }
        catch (let error)
        {
            print("\nUnable to decode JSON into ReplicantServerConfig: \(error)\n")
            return nil
        }
    }

}
