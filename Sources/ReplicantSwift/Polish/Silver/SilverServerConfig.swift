//
//  SilverServerConfig.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import SwiftQueue

public struct SilverServerConfig: PolishServerConfig, Codable
{ 
    public let serverPublicKey: Data
    public let serverPrivateKey: Data
    public let chunkSize: UInt16
    public let chunkTimeout: Int
    
    
    public func construct(logQueue: Queue<String>) -> PolishServer?
    {
        let silverServer = SilverServer(logQueue: logQueue, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
        
        return silverServer
    }
}
