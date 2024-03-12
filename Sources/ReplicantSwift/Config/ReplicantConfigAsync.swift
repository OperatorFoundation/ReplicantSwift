//
//  ReplicantConfigAsync.swift
//
//
//  Created by Mafalda on 3/12/24.
//

import Foundation

// TODO: Should eventually replace the old non-async Replicant config classes
public class ReplicantConfigAsync
{
    public struct ServerConfig: Codable
    {
        public let serverAddress: String
        public let serverIP: String
        public let serverPort: UInt16
        public let polish: PolishServerConfig?
        public let toneburst: ToneBurstAsync?
        public let toneburstType: ToneBurstType?
        public var transportName = "replicant"
        
        enum CodingKeys: String, CodingKey
        {
            case serverAddress
            case polish
            case toneburst
            case toneburstType
            case transportName = "transport"
        }
        
        public init(serverAddress: String, polish maybePolish: PolishServerConfig?, toneBurst maybeToneBurst: ToneBurstAsync?) throws
        {
            let addressStrings = serverAddress.replacingOccurrences(of: " ", with: "").split(separator: ":")
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding Replicant server config data: invalid server port \(addressStrings[1])")
                throw ReplicantError.invalidPort
            }
            
            self.serverAddress = serverAddress
            self.serverIP = String(addressStrings[0])
            self.serverPort = port
            self.polish = maybePolish
            self.toneburst = maybeToneBurst
            self.toneburstType = toneburst?.type
        }
        
        public init?(from data: Data)
        {
            let decoder = JSONDecoder()
            do
            {
                let decoded = try decoder.decode(ServerConfig.self, from: data)
                
                self = decoded
            }
            catch
            {
                print("Error received while attempting to decode a Replicant server config json file: \(error)")
                return nil
            }
        }
        
        public init?(withConfigAtPath path: String)
        {
            let url = URL(fileURLWithPath: path)
            
            do
            {
                let data = try Data(contentsOf: url)
                self.init(from: data)
            }
            catch
            {
                print("Error decoding Replicant server config file: \(error)")
                
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let address = try container.decode(String.self, forKey: .serverAddress)
            let addressStrings = address.replacingOccurrences(of: " ", with: "").split(separator: ":")
            let ipAddress = String(addressStrings[0])
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding Replicant server config - invalid server port: \(addressStrings[1])")
                throw ReplicantError.decoderFailure
            }
            
            self.serverAddress = address
            self.serverIP = ipAddress
            self.serverPort = port
            self.polish = try container.decodeIfPresent(PolishServerConfig.self, forKey: .polish)
            self.toneburstType = try container.decodeIfPresent(ToneBurstType.self, forKey: .toneburstType)
            
            // TODO: Support additional ToneBurst types
            switch self.toneburstType
            {
                case .starburst:
                    self.toneburst = try container.decodeIfPresent(StarburstAsync.self, forKey: .toneburst)
                case .none:
                    print("No supported Toneburst type was indicated while decoding a Replicant server config. Skipping Toneburst setup.")
                    self.toneburst = nil
            }
        }
        
        public func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(serverAddress, forKey: .serverAddress)
            try container.encode(transportName, forKey: .transportName)
            try container.encode(polish, forKey: .polish)
            try container.encode(toneburstType, forKey: .toneburstType)
            
            // TODO: Support additional ToneBurst types
            switch toneburstType
            {
                case .starburst:
                    if let starburst = toneburst as? Starburst
                    {
                        try container.encode(starburst, forKey: .toneburst)
                    }
                case .none:
                    print("Encoded a Replicant server config without a Toneburst.")
            }
        }
        
        /// Creates and returns a JSON representation of the ReplicantServerConfig struct.
        public func createJSON() -> Data?
        {
            let encoder = JSONEncoder()
            encoder.outputFormatting.insert(.prettyPrinted)
            encoder.outputFormatting.insert(.withoutEscapingSlashes)
            
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
    }
    
    public struct ClientConfig: Codable
    {
        public let serverAddress: String
        public let serverIP: String
        public let serverPort: UInt16
        public let polish: PolishServerConfig?
        public let toneburst: ToneBurstAsync?
        public let toneburstType: ToneBurstType?
        public var transportName = "replicant"
        
        enum CodingKeys: String, CodingKey
        {
            case serverAddress
            case polish
            case toneburst
            case toneburstType
            case transportName = "transport"
        }
        
        public init(serverAddress: String, polish maybePolish: PolishServerConfig?, toneBurst maybeToneBurst: ToneBurstAsync?) throws
        {
            let addressStrings = serverAddress.replacingOccurrences(of: " ", with: "").split(separator: ":")
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding Replicant client config data: invalid server port \(addressStrings[1])")
                throw ReplicantError.invalidPort
            }
            
            self.serverAddress = serverAddress
            self.serverIP = String(addressStrings[0])
            self.serverPort = port
            self.polish = maybePolish
            self.toneburst = maybeToneBurst
            self.toneburstType = toneburst?.type
        }
        
        public init?(from data: Data)
        {
            let decoder = JSONDecoder()
            do
            {
                let decoded = try decoder.decode(ClientConfig.self, from: data)
                
                self = decoded
            }
            catch
            {
                print("Error received while attempting to decode a Replicant client config json file: \(error)")
                return nil
            }
        }
        
        public init?(withConfigAtPath path: String)
        {
            let url = URL(fileURLWithPath: path)
            
            do
            {
                let data = try Data(contentsOf: url)
                self.init(from: data)
            }
            catch
            {
                print("Error decoding Replicant client config file: \(error)")
                
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let address = try container.decode(String.self, forKey: .serverAddress)
            let addressStrings = address.replacingOccurrences(of: " ", with: "").split(separator: ":")
            let ipAddress = String(addressStrings[0])
            guard let port = UInt16(addressStrings[1]) else
            {
                print("Error decoding Replicant client config - invalid server port: \(addressStrings[1])")
                throw ReplicantError.decoderFailure
            }
            
            self.serverAddress = address
            self.serverIP = ipAddress
            self.serverPort = port
            self.polish = try container.decodeIfPresent(PolishServerConfig.self, forKey: .polish)
            self.toneburstType = try container.decodeIfPresent(ToneBurstType.self, forKey: .toneburstType)
            
            // TODO: Support additional ToneBurst types
            switch self.toneburstType
            {
                case .starburst:
                    self.toneburst = try container.decodeIfPresent(StarburstAsync.self, forKey: .toneburst)
                case .none:
                    print("No supported Toneburst type was indicated while decoding a Replicant client config. Skipping Toneburst setup.")
                    self.toneburst = nil
            }
        }
        
        public func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(serverAddress, forKey: .serverAddress)
            try container.encode(transportName, forKey: .transportName)
            try container.encode(polish, forKey: .polish)
            try container.encode(toneburstType, forKey: .toneburstType)
            
            // TODO: Support additional ToneBurst types
            switch toneburstType
            {
                case .starburst:
                    if let starburst = toneburst as? Starburst
                    {
                        try container.encode(starburst, forKey: .toneburst)
                    }
                case .none:
                    print("Encoded a Replicant client config without a Toneburst.")
            }
        }
        
        /// Creates and returns a JSON representation of the ReplicantClientConfig struct.
        public func createJSON() -> Data?
        {
            let encoder = JSONEncoder()
            encoder.outputFormatting.insert(.prettyPrinted)
            encoder.outputFormatting.insert(.withoutEscapingSlashes)
            
            do
            {
                let clientConfigData = try encoder.encode(self)
                return clientConfigData
            }
            catch (let error)
            {
                print("Failed to encode a Replicant client config into JSON format: \(error)")
                return nil
            }
        }
    }
}
