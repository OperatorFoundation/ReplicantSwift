//
//  ReplicantConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/14/18.
//

import Foundation
import Song

public struct ReplicantClientConfig: Codable
{
    //public static var supportsSecureCoding: Bool = true
    public let serverAddress: String
    public var polish: PolishClientConfig?
    public var toneBurst: ToneBurstClientConfig?
    public var transport: String
    
    public init?(from data: Data)
    {
        let decoder = JSONDecoder()
        do
        {
            let decoded = try decoder.decode(ReplicantClientJsonConfig.self, from: data)
            let toneBurstConfig = ToneBurstClientConfig.starburst(config: StarburstConfig(mode: .SMTPClient))
            let maybePolishConfig = decoded.polish
            self.init(serverAddress: decoded.serverAddress, polish: maybePolishConfig, toneBurst: toneBurstConfig, transport: decoded.transport)
        }
        catch let decodeError
        {
            print("Error decoding ReplicantConfig data: \(decodeError)")
            return nil
        }
    }
    
    public init(serverAddress: String, polish maybePolish: PolishClientConfig?, toneBurst maybeToneBurst: ToneBurstClientConfig?, transport: String)
    {
        self.serverAddress = serverAddress
        self.polish = maybePolish
        self.toneBurst = maybeToneBurst
        self.transport = transport
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
}

public struct ReplicantClientJsonConfig: Codable
{
    public let serverAddress: String
    public var polish: PolishClientConfig?
    public var toneburst: ToneBurstClientJsonConfig?
    public var transport: String
    
    public init(serverAddress: String, polish maybePolish: PolishClientConfig?, toneBurst maybeToneBurst: ToneBurstClientJsonConfig?, transport: String)
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
