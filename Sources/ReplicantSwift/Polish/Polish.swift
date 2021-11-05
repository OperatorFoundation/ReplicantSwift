//
//  Polish.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Crypto

import Foundation
import Transmission

public protocol PolishConnection
{
    var chunkSize: UInt16 { get }
    var chunkTimeout: Int { get }
    
    mutating func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    func polish(inputData: Data) -> Data?
    func unpolish(polishedData: Data) -> Data?
}

public protocol PolishServer
{
    var chunkSize: UInt16 { get }
    var chunkTimeout: Int { get }
    
    func newConnection(connection: Connection) -> PolishConnection?
}

func generateRandomBytes(count: Int) -> Data
{
    var bytes = [UInt8]()
    for _ in 1...count
    {
        bytes.append(UInt8.random(in: 0...255))
    }
    
    return Data(bytes)
}
