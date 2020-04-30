//
//  SilverServerConfig.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import SwiftQueue

struct SilverServerConfig: PolishServerConfig, Codable
{
    let serverPublicKey: Data
    let serverPrivateKey: Data
    let chunkSize: UInt16
    let chunkTimeout: Int
    
    func construct(logQueue: Queue<String>) -> PolishServer?
    {
        SilverServer(logQueue: logQueue, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    }
}
