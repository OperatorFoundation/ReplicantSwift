//
//  File.swift
//  
//
//  Created by Mafalda on 1/19/22.
//

import Foundation
import Logging

public protocol PolishConfig
{
    func getPolish(logger: Logger) -> Polish?
}

public enum PolishType: String, Codable
{
    case silver = "silver"
}

public enum PolishClientConfig: Codable
{
    case silver(serverPublicKeyData: Data, chunkSize: UInt16, chunkTimeout: Int)
    //func construct(logger: Logger) -> PolishConnection?
}

extension PolishClientConfig: PolishConfig
{
    public func getPolish(logger: Logger) -> Polish?
    {
        switch self
        {
            case .silver(let serverPublicKeyData, let chunkSize, let chunkTimeout):
                return SilverClientConnection(logger: logger, serverPublicKeyData: serverPublicKeyData, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
        }
    }    
}

public enum PolishServerConfig
{
    case silver(chunkSize: UInt16, chunkTimeout: Int, clientPublicKeyData: Data? = nil)
    //func construct(logger: Logger) -> PolishServer?
}

extension PolishServerConfig: PolishConfig, Codable
{
    public func getPolish(logger: Logger) -> Polish?
    {
        switch self
        {
            case .silver(let chunkSize, let chunkTimeout, let clientPublicKeyData):
                return SilverServer(logger: logger, chunkSize: chunkSize, chunkTimeout: chunkTimeout, clientPublicKeyData: clientPublicKeyData)
        }
    }
}

