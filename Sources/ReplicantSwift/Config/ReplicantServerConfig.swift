//
//  ReplicantServerConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/7/18.
//

import Foundation

public struct ReplicantServerConfig
{
    public let serverAddress: String
    public var polish: PolishServerConfig?
    public var toneBurst: ToneBurst?
    public var transport: String
    
    enum CodingKeys: String, CodingKey
    {
        case serverAddress
        case polish
        case toneburst
        case transport
    }
    
    public init(serverAddress: String, polish maybePolish: PolishServerConfig?, toneBurst maybeToneBurst: ToneBurst?, transport: String)
    {
        self.serverAddress = serverAddress
        self.polish = maybePolish
        self.toneBurst = maybeToneBurst
        self.transport = transport
    }
    
    public init?(withConfigAtPath path: String)
    {
        guard let config = ReplicantServerConfig.parseJSON(atPath: path)
        else
        {
            return nil
        }
        
        self = config
    }
    
    /// Creates and returns a JSON representation of the ReplicantServerConfig struct.
    public func createJSON() -> Data?
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do
        {
            let serverConfigData = try encoder.encode(self)
            return serverConfigData
        }
        catch (let error)
        {
            print("Failed to encode Server config into JSON format: \(error)")
            return nil
        }
    }
    
    /// Checks for a valid JSON at the provided path and attempts to decode it into a Replicant server configuration file. Returns a ReplicantConfig struct if it is successful
    /// - Parameters:
    ///     - path: The complete path where the config file is located.
    /// - Returns: The ReplicantServerConfig struct that was decoded from the JSON file located at the provided path, or nil if the file was invalid or missing.
    static public func parseJSON(atPath path: String) -> ReplicantServerConfig?
    {
        let filemanager = FileManager()
        let decoder = JSONDecoder()
        
        guard let jsonData = filemanager.contents(atPath: path)
        else
        {
            print("\nUnable to get JSON data at path: \(path)\n")
            return nil
        }
        
        do
        {
            let jsonConfig = try decoder.decode(ReplicantServerConfig.self, from: jsonData)
            let config = ReplicantServerConfig(serverAddress: jsonConfig.serverAddress, polish: jsonConfig.polish, toneBurst: jsonConfig.toneBurst, transport: jsonConfig.transport)
            
            return config
        }
        catch (let error)
        {
            print("\nUnable to decode JSON into ReplicantServerConfig: \(error)\n")
            return nil
        }
    }
}

extension ReplicantServerConfig: Encodable
{
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serverAddress, forKey: .serverAddress)
        try container.encode(transport, forKey: .transport)
        try container.encode(polish, forKey: .polish)
        
        // TODO: Add additional Toneburst types here
        if let starburst = toneBurst as? Starburst
        {
            try container.encode(starburst, forKey: .toneburst)
        }
    }
}

extension ReplicantServerConfig: Decodable
{
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.serverAddress = try container.decode(String.self, forKey: .serverAddress)
        self.transport = try container.decode(String.self, forKey: .transport)
        self.polish = try container.decodeIfPresent(PolishServerConfig.self, forKey: .polish)
        
        // TODO: Add additional ToneBurst types here
        if let starburst = try container.decodeIfPresent(Starburst.self, forKey: .toneburst)
        {
            self.toneBurst = starburst
        }
    }
}

//public struct ReplicantServerJsonConfig: Codable
//{
//    public let serverAddress: String
//    public var polish: PolishServerConfig?
//    public var toneburst: ToneBurstServerJsonConfig?
//    public var transport: String
//
//    public init(serverAddress: String, polish maybePolish: PolishServerConfig?, toneBurst maybeToneBurst: ToneBurstServerJsonConfig?, transport: String)
//    {
//        self.serverAddress = serverAddress
//        self.polish = maybePolish
//        self.toneburst = maybeToneBurst
//        self.transport = transport
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
//}
