//
//  SilverClientConfig.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import Logging

public struct SilverClientConfig: PolishClientConfig
{
    public let serverKey: Data
    public let chunkSize: UInt16
    public let chunkTimeout: Int
    
    public func construct(logger: Logger) -> PolishConnection?
    {
        return SilverClientConnection(logger: logger, serverPublicKeyData: serverKey, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    } 
}

extension SilverClientConfig: Codable {}
