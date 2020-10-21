//
//  WhalesongServer.swift
//  ReplicantSwift
//
//  Created by Dr. Brandon Wiley on 2/21/19.
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
public class WhalesongServer: Whalesong
{
}

extension WhalesongServer: ToneBurst
{
    public func play(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        self.toneBurstReceive(connection: connection, finalToneSent: false, completion: completion)
    }
}
