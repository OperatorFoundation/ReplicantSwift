//
//  MonotoneClient.swift
//  ReplicantSwift
//
//  Created by Mafalda on 11/14/19.
//

import Foundation
import Datable
import Transmission
//import Monolith

/// Injects byte sequences into a stream of bytes
public class MonotoneClient: Whalesong
{
}

extension MonotoneClient: ToneBurst
{
    public func perform(connection: Transmission.Connection, completion: @escaping (Error?) -> Void)
    {
        
        let sendState = generate()
        
        switch sendState
        {
        case .generating(let nextTone):
            print("\nGenerating tone bursts.\n")
            guard connection.write(data: nextTone) else
            {
                print("Received error while sending tone burst")
                completion(MonotoneError.generateFailure)
                return
            }

            self.toneBurstReceive(connection: connection, finalToneSent: false, completion: completion)
        case .completion:
            print("\nGenerated final toneburst\n")
            toneBurstReceive(connection: connection, finalToneSent: true, completion: completion)
            
        case .failure:
            print("\nFailed to generate requested ToneBurst")
            completion(WhalesongError.generateFailure)
        }
    }
}
