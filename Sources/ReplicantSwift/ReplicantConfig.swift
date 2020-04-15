//
//  ReplicantConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/14/18.
//

import Foundation

public class ReplicantConfig: NSObject, Codable, NSSecureCoding
{
    let replicantConfigKey = "ReplicantConfig"
    public static var supportsSecureCoding: Bool = true
    
    public var serverPublicKey: Data
    public var chunkSize: UInt16
    public var chunkTimeout: Int
    public var toneBurst: ToneBurstClientConfig?
    
    public func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self, forKey: replicantConfigKey)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        if let obj = aDecoder.decodeObject(of:ReplicantConfig.self, forKey: replicantConfigKey)
        {
            guard obj.chunkSize >= keySize + aesOverheadSize
                else
            {
                print("\nUnable to initialize ReplicantConfig: chunkSize (\(obj.chunkSize)) cannot be smaller than keySize + aesOverheadSize (\(keySize + aesOverheadSize))\n")
                return nil
            }

            self.serverPublicKey = obj.serverPublicKey
            self.chunkSize = obj.chunkSize
            self.chunkTimeout = obj.chunkTimeout
            self.toneBurst = obj.toneBurst
        }
        else
        {
            return nil
        }
    }
    
    public init?(serverPublicKey: Data, chunkSize: UInt16, chunkTimeout: Int, toneBurst: ToneBurstClientConfig?)
    {
        guard chunkSize >= keySize + aesOverheadSize
            else
        {
            print("\nUnable to initialize ReplicantConfig: chunkSize (\(chunkSize)) cannot be smaller than keySize + aesOverheadSize (\(keySize + aesOverheadSize))\n")
            return nil
        }

        self.serverPublicKey = serverPublicKey
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        self.toneBurst = toneBurst
    }
    
    public convenience init?(withConfigAtPath path: String)
    {
        guard let config = ReplicantConfig.parseJSON(atPath:path)
            else
        {
            return nil
        }
        
        self.init(serverPublicKey: config.serverPublicKey,
                  chunkSize: config.chunkSize,
                  chunkTimeout: config.chunkTimeout,
                  toneBurst: config.toneBurst)
    }
    
    /// Creates and returns a JSON representation of the ReplicantConfig struct.
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
    
    /// Checks for a valid JSON at the provided path and attempts to decode it into a Replicant client configuration file. Returns a ReplicantConfig struct if it is successful
    /// - Parameters:
    ///     - path: The complete path where the config file is located.
    /// - Returns: The ReplicantConfig struct that was decoded from the JSON file located at the provided path, or nil if the file was invalid or missing.
    public static func parseJSON(atPath path: String) -> ReplicantConfig?
    {
        let fileManager = FileManager()
        
        
        guard let jsonData = fileManager.contents(atPath: path)
            else
        {
            print("\nUnable to get JSON data at pathe: \(path)\n")
            return nil
        }
        
        return parse(jsonData: jsonData)
    }
    
    public static func parse(jsonData: Data) -> ReplicantConfig?
    {
        let decoder = JSONDecoder()
        
        do
        {
            let config = try decoder.decode(ReplicantConfig.self, from: jsonData)
            return config
        }
        catch (let error)
        {
            print("\nUnable to decode JSON into ReplicantConfig: \(error)\n")
            return nil
        }
    }
}

//extension ReplicantConfig: Equatable
//{
//    public static func == (lhs: ReplicantConfig, rhs: ReplicantConfig) -> Bool
//    {
//
//        return lhs.chunkSize == rhs.chunkSize &&
//            lhs.chunkTimeout == rhs.chunkTimeout &&
//            lhs.addSequences == rhs.addSequences &&
//            lhs.removeSequences == rhs.removeSequences &&
//            lhs.serverPublicKey == rhs.serverPublicKey
//    }
//}
