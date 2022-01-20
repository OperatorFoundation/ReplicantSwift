//
//  SilverServerConfig.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//
//
//import Foundation
//import Logging
//
//public struct SilverServerConfig: Polish, Codable
//{ 
//    public let serverPublicKey: Data
//    public let serverPrivateKey: Data
//    public let chunkSize: UInt16
//    public let chunkTimeout: Int
//    
//    public func construct(logger: Logger) -> PolishServer?
//    {
//        let silverServer = SilverServer(logger: logger, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
//        
//        return silverServer
//    }
//}
