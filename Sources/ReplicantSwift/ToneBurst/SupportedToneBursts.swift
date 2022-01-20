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

public enum ToneBurstClientConfig
{
    case whalesong(client: WhalesongClient)
}

extension ToneBurstClientConfig: ToneBurstConfig
{
    public func getToneBurst() -> ToneBurst {
        switch self
        {
            case .whalesong(client: let client):
                return client
        }
    }
}

extension ToneBurstClientConfig: Codable
{
    enum CodingKeys: CodingKey
    {
        case whalesong
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do
        {
            let whalesongValue =  try container.decode(WhalesongClient.self, forKey: .whalesong)
            self = .whalesong(client: whalesongValue)
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
        }
    }
}

public enum ToneBurstServerConfig
{
    case whalesong(server: WhalesongServer)
}

extension ToneBurstServerConfig: ToneBurstConfig
{
    public func getToneBurst() -> ToneBurst {
        switch self
        {
        case .whalesong(server: let server):
            return server
        }
    }
}

extension ToneBurstServerConfig: Codable
{
    enum CodingKeys: CodingKey
    {
        case whalesong
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
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
        }
    }
}
