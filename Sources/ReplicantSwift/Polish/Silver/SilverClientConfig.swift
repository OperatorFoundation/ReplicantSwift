//
//  SilverClientConfig.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import SwiftQueue

struct SilverClientConfig: PolishClientConfig, Codable
{
    let serverKey: Data
    let chunkSize: UInt16
    let chunkTimeout: Int
    
    func construct(logQueue: Queue<String>) -> PolishConnection? {
        return SilverClientConnection(logQueue: logQueue, serverPublicKeyData: serverKey, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    } 
}
