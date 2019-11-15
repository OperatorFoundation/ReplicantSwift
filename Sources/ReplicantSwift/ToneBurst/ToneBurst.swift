//
//  ToneBurst.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation
import Datable
import Transport

/// Injects byte sequences into a stream of bytes
public protocol ToneBurst: Codable
{
    mutating func play(connection: Connection, completion: @escaping (Error?) -> Void)
}
