//
//  ReplicantConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/14/18.
//

import Foundation
import Song

public struct ReplicantConfig<PolishClientConfigType>: Codable where PolishClientConfigType: PolishClientConfig
{
    //public static var supportsSecureCoding: Bool = true
    public let serverIP: String
    public let port: UInt16
    public let chunkSize: UInt16?
    public let chunkTimeout: Int?
    public let serverPublicKey: String?
    public var polish: PolishClientConfigType?
    public var toneBurst: ToneBurstClientConfig?
    
    public init?(from data: Data)
    {
        let decoder = JSONDecoder()
        do
        {
            let decoded = try decoder.decode(ReplicantConfig.self, from: data)
            
            if let actualChunkSize = decoded.chunkSize, let actualChunkTimeout = decoded.chunkTimeout, let actualServerKey = decoded.serverPublicKey
            {
                guard let actualPolishConfig = SilverClientConfig(serverKey: actualServerKey, chunkSize: actualChunkSize, chunkTimeout: actualChunkTimeout) as? PolishClientConfigType
                else
                {
                    print("Failed to create a polish config using the provided parameters:\nchunkSize - \(actualChunkSize)\nchunkTimeout - \(actualChunkTimeout)\nserverKey - \(actualServerKey)")
                    return nil
                }
                
                // TODO: This does not currently handle toneburst
                var maybeToneburstConfig: ToneBurstClientConfig?
                
                self.init(serverIP: decoded.serverIP, port: decoded.port, polish: actualPolishConfig, toneBurst: maybeToneburstConfig)
                
            }
            else
            {
                // TODO: This does not currently handle toneburst
                var maybeToneburstConfig: ToneBurstClientConfig?
                
                self.init(serverIP: decoded.serverIP, port: decoded.port, polish: nil, toneBurst: maybeToneburstConfig)
            }
        }
        catch let decodeError
        {
            print("Error decoding ReplicantConfig data: \(decodeError)")
            return nil
        }
                
        
    }
    
    public init?(serverIP: String, port: UInt16, polish: PolishClientConfigType?, toneBurst: ToneBurstClientConfig?)
    {
        // TODO: This will only work with silver polish types
        guard let silverPolish = polish as? SilverClientConfig
        else
        {
            print("Failed to cast polish config to SilverClientConfig")
            return nil
        }
        
        self.serverIP = serverIP
        self.port = port
        self.chunkSize = silverPolish.chunkSize
        self.chunkTimeout = silverPolish.chunkTimeout
        self.serverPublicKey = String(data: silverPolish.serverKey)
        self.polish = polish
        self.toneBurst = toneBurst
    }
    
    public init?(withConfigAtPath path: String)
    {
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else {return nil}
        self.init(from: data)
    }
    
    public func createSong(filePath: String) throws
    {
        let songEncoder = SongEncoder()
        let songData = try songEncoder.encode(self)
        let dirURL = URL(fileURLWithPath: filePath)
        
        try songData.write(to: dirURL)
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
            print("\nUnable to get JSON data at path: \(path)\n")
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
