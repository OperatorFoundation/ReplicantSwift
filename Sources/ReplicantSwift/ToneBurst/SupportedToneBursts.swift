//
//  SupportedToneBurst.swift
//  ReplicantSwift
//
//  Created by Dr. Brandon Wiley on 2/21/19.
//

import Foundation

public protocol ToneBurstConfig
{
    func getToneBurst() -> ToneBurst
}

public enum ToneBurstType: String, Codable
{
    case whalesong = "whalesong"
    case monotone = "monotone"
    case starburst = "starburst"
}

public enum ToneBurstClientConfig
{
    case whalesong(client: WhalesongClient)
    case monotone(config: MonotoneConfig)
    case starburst(config: StarburstConfig)
}

extension ToneBurstClientConfig: ToneBurstConfig
{
    public func getToneBurst() -> ToneBurst {
        switch self
        {
            case .whalesong(client: let client):
                return client
            case .monotone(config: let monotoneConfig):
                return monotoneConfig.construct()
            case .starburst(config: let config):
                return config.construct()
        }
    }
}

extension ToneBurstClientConfig: Codable
{
    enum CodingKeys: CodingKey
    {
        case whalesong
        case monotone
        case starburst
    }
    
    public init(from decoder: Decoder) throws
    {
        // FIXME: This only inits starburst flavor
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do
        {
            let starburstConfig =  try container.decode(StarburstConfig.self, forKey: .starburst)
            self = .starburst(config: starburstConfig)
        }
        catch
        {
            throw error
        }
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .whalesong(let client):
                try container.encode(client, forKey: .whalesong)
            case .monotone(config: let config):
                try container.encode(config, forKey: .monotone)
            case .starburst(config: let config):
                try container.encode(config, forKey: .starburst)
        }
    }
}

public enum ToneBurstServerConfig
{
    case whalesong(server: WhalesongServer)
    case monotone(config: MonotoneConfig)
    case starburst(config: StarburstConfig)
}

extension ToneBurstServerConfig: ToneBurstConfig
{
    public func getToneBurst() -> ToneBurst
    {
        switch self
        {
            case .whalesong(server: let server):
                return server
            case .monotone(config: let monotoneConfig):
                return monotoneConfig.construct()
            case .starburst(config: let config):
                return config.construct()
        }
    }
}

extension ToneBurstServerConfig: Codable
{
    enum CodingKeys: CodingKey
    {
        case whalesong
        case monotone
        case starburst
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // FIXME: This only inits starburst flavor
        do
        {
            let starburstConfig =  try container.decode(StarburstConfig.self, forKey: .starburst)
            self = .starburst(config: starburstConfig)
        }
        catch
        {
            throw error
        }
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self
        {
            case .whalesong(let server):
                try container.encode(server, forKey: .whalesong)
            case .monotone(config: let monotoneConfig):
                try container.encode(monotoneConfig, forKey: .monotone)
            case .starburst(config: let config):
                try container.encode(config, forKey: .starburst)
        }
    }
}
