//
//  ToneBurst.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation
import Datable
import Transmission

/// Injects byte sequences into a stream of bytes
public protocol ToneBurst: Codable
{
    var type: ToneBurstType { get set }
    
    mutating func perform(connection: Transmission.Connection) throws
}

