//
//  MonotoneServer.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import Datable
import Transport
#if os(Linux)
import NetworkLinux
#else
import Network
#endif

/// Injects byte sequences into a stream of bytes
public class MonotoneServer: Whalesong
{
}

extension MonotoneServer: ToneBurst
{
    public func play(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        self.toneBurstReceive(connection: connection, finalToneSent: false, completion: completion)
    }
}
