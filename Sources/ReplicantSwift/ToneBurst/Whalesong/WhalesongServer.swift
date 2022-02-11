//
//  WhalesongServer.swift
//  ReplicantSwift
//
//  Created by Dr. Brandon Wiley on 2/21/19.
//

import Foundation
import Datable
import Transmission

/// Injects byte sequences into a stream of bytes
public class WhalesongServer: Whalesong
{
}

extension WhalesongServer: ToneBurst
{
    public func perform(connection: Transmission.Connection, completion: @escaping (Error?) -> Void)
    {
        self.toneBurstReceive(connection: connection, finalToneSent: false, completion: completion)
    }
}
