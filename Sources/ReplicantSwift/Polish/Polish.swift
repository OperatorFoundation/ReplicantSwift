//
//  Polish.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import Transport

public protocol PolishConnection
{
    mutating func handshake(connection: Connection, completion: @escaping (Error?) -> Void)
    func polish(inputData: Data) -> Data?
    func unpolish(polishedData: Data) -> Data?
}

public protocol PolishServer
{
    func newConnection(connection: Connection) -> PolishConnection?
}

func generateRandomBytes(count: Int) -> Data? {
    var bytes = [UInt8](repeating: 0, count: count)
    let result = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

    guard result == errSecSuccess else {
        print("Problem generating random bytes")
        return nil
    }

    return Data(bytes)
}
