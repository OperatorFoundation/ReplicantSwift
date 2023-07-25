//
//  ReplicantConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/14/18.
//

import Foundation
import Song

public struct ReplicantClientConfig
{
    public let serverAddress: String
    public let serverIP: String
    public let serverPort: UInt16
    public var polish: PolishClientConfig?
    public var toneBurst: ToneBurst?
    public var transport: String
    
    enum CodingKeys: String, CodingKey
    {
        case serverAddress
        case polish
        case toneburst
        case transport
    }
    
    public init?(from data: Data)
    {
        let decoder = JSONDecoder()
        do
        {
            let decoded = try decoder.decode(ReplicantClientConfig.self, from: data)
            let toneBurst = decoded.toneBurst
            let maybePolishConfig = decoded.polish
            
            self.init(serverAddress: decoded.serverAddress, polish: maybePolishConfig, toneBurst: toneBurst, transport: decoded.transport)
        }
        catch let decodeError
        {
            print("Error decoding ReplicantConfig data: \(decodeError)")
            return nil
        }
    }
    
    public init?(serverAddress: String, polish maybePolish: PolishClientConfig?, toneBurst maybeToneBurst: ToneBurst?, transport: String)
    {
        let addressStrings = serverAddress.split(separator: ":")
        let ipAddress = String(addressStrings[0])
        guard let port = UInt16(addressStrings[1]) else
        {
            print("Error decoding ReplicantConfig data: invalid server port")
            return nil
        }
        
        self.init(serverAddress: serverAddress, serverIP: ipAddress, serverPort: port, polish: maybePolish, toneBurst: maybeToneBurst, transport: transport)
    }
    
    public init(serverAddress: String, serverIP: String, serverPort: UInt16, polish maybePolish: PolishClientConfig?, toneBurst maybeToneBurst: ToneBurst?, transport: String)
    {
        self.serverAddress = serverAddress
        self.serverIP = serverIP
        self.serverPort = serverPort
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

extension ReplicantClientConfig: Encodable
{
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serverAddress, forKey: .serverAddress)
        try container.encode(transport, forKey: .transport)
        try container.encode(polish, forKey: .polish)
        
        // TODO: Add additional Toneburst types here
        if let toneBurst = toneBurst
        {
            switch toneBurst.type
            {
                case .starburst:
                    if let starburst = toneBurst as? Starburst
                    {
                        try container.encode(starburst, forKey: .toneburst)
                    }
            }
        }
    }
}

extension ReplicantClientConfig: Decodable
{
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let address = try container.decode(String.self, forKey: .serverAddress)
        let addressStrings = address.split(separator: ":")
        let ipAddress = String(addressStrings[0])
        guard let port = UInt16(addressStrings[1]) else
        {
            print("Error decoding ReplicantConfig data: invalid server port")
            throw ReplicantError.decoderFailure
        }
        
        self.serverAddress = address
        self.serverIP = ipAddress
        self.serverPort = port
        self.transport = try container.decode(String.self, forKey: .transport)
        self.polish = try container.decodeIfPresent(PolishClientConfig.self, forKey: .polish)
        
        // TODO: Add additional Toneburst types here
        if let starburst = try container.decodeIfPresent(Starburst.self, forKey: .toneburst)
        {
            self.toneBurst = starburst
        }
    }
}

//public struct ReplicantClientJsonConfig: Codable
//{
//    public let serverAddress: String
//    public var polish: PolishClientConfig?
//    public var toneburst: ToneBurstClientJsonConfig?
//    public var transport: String
//
//    public init(serverAddress: String, polish maybePolish: PolishClientConfig?, toneBurst maybeToneBurst: ToneBurstClientJsonConfig?, transport: String)
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
