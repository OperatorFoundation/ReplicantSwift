//
//  ReplicantServerConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/7/18.
//

import Foundation

public struct ReplicantServerConfig: Codable
{
    public let serverAddress: String
    public var polish: PolishServerConfig?
    public var toneburst: ToneBurstServerConfig?
    public var transport: String
    
    public init(serverAddress: String, polish maybePolish: PolishServerConfig?, toneBurst maybeToneBurst: ToneBurstServerConfig?, transport: String)
    {
        self.serverAddress = serverAddress
        self.polish = maybePolish
        self.toneburst = maybeToneBurst
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
            let jsonConfig = try decoder.decode(ReplicantServerJsonConfig.self, from: jsonData)
            let toneBurstConfig = ToneBurstServerConfig.starburst(config: StarburstConfig(mode: .SMTPServer))
            let config = ReplicantServerConfig(serverAddress: jsonConfig.serverAddress, polish: jsonConfig.polish, toneBurst: toneBurstConfig, transport: jsonConfig.transport)
            
            return config
        }
        catch (let error)
        {
            print("\nUnable to decode JSON into ReplicantServerConfig: \(error)\n")
            return nil
        }
    }
}

public struct ReplicantServerJsonConfig: Codable
{
    public let serverAddress: String
    public var polish: PolishServerConfig?
    public var toneburst: ToneBurstServerJsonConfig?
    public var transport: String
    
    public init(serverAddress: String, polish maybePolish: PolishServerConfig?, toneBurst maybeToneBurst: ToneBurstServerJsonConfig?, transport: String)
    {
        self.serverAddress = serverAddress
        self.polish = maybePolish
        self.toneburst = maybeToneBurst
        self.transport = transport
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
}
