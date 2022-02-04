////
////  SilverClientConfig.swift
////  ReplicantSwift
////
////  Created by Mafalda on 4/28/20.
////
////
//import Foundation
//import Logging
//
//public struct SilverClientConfig//: PolishClientConfig
//{
//    public let serverKey: Data
//    public let chunkSize: UInt16
//    public let chunkTimeout: Int
//    
//    public init(serverKey: Data, chunkSize: UInt16, chunkTimeout: Int)
//    {
//        self.serverKey = serverKey
//        self.chunkSize = chunkSize
//        self.chunkTimeout = chunkTimeout
//    }
//    
//    public init?(serverKey: String, chunkSize: UInt16, chunkTimeout: Int)
//    {
//        guard let serverKeyData = Data(base64Encoded: serverKey)
//        else
//        {
//            return nil
//        }
//        
//        self.serverKey = serverKeyData
//        self.chunkSize = chunkSize
//        self.chunkTimeout = chunkTimeout
//    }
//    
//    public func construct(logger: Logger) -> PolishConnection?
//    {
//        return SilverClientConnection(logger: logger, serverPublicKeyData: serverKey, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
//    }
//}
//
//extension SilverClientConfig: Codable {}
