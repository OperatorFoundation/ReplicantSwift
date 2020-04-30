//
//  SilverClientConfig.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import SwiftQueue

public struct SilverClientConfig: PolishClientConfig, Codable
{
    public let serverKey: Data
    public let chunkSize: UInt16
    public let chunkTimeout: Int
    
    public func construct(logQueue: Queue<String>) -> PolishConnection?
    {
        return SilverClientConnection(logQueue: logQueue, serverPublicKeyData: serverKey, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    } 
}
