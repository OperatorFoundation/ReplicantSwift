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
}

public enum ToneBurstClientConfig
{
    case whalesong(client: WhalesongClient)
    case monotone(config: MonotoneConfig)
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
        }
    }
}

extension ToneBurstClientConfig: Codable
{
    enum CodingKeys: CodingKey
    {
        case whalesong
        case monotone
    }
    
    public init(from decoder: Decoder) throws
    {
        // FIXME: This only inits monotone flavor
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do
        {
            let monotoneValue =  try container.decode(MonotoneConfig.self, forKey: .monotone)
            self = .monotone(config: monotoneValue)
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
        }
    }
}

public enum ToneBurstServerConfig
{
    case whalesong(server: WhalesongServer)
    case monotone(config: MonotoneConfig)
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
        }
    }
}

extension ToneBurstServerConfig: Codable
{
    enum CodingKeys: CodingKey
    {
        case whalesong
        case monotone
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // FIXME: This only inits whalesong flavor
        do
        {
            let whalesongValue =  try container.decode(WhalesongServer.self, forKey: .whalesong)
            self = .whalesong(server: whalesongValue)
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
        }
    }
}
