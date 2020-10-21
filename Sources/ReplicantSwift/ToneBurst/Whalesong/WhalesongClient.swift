//
//  Whalesong.swift
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
public class WhalesongClient: Whalesong
{
}

extension WhalesongClient: ToneBurst
{
    public func play(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        let sendState = generate()
        
        switch sendState
        {
        case .generating(let nextTone):
            print("\nGenerating tone bursts.\n")
            connection.send(content: nextTone, contentContext: .defaultMessage, isComplete: false, completion: NWConnection.SendCompletion.contentProcessed(
                {
                    (maybeToneSendError) in
                    
                    guard maybeToneSendError == nil
                        else
                    {
                        print("Received error while sending tone burst: \(maybeToneSendError!)")
                        return
                    }
                    
                    self.toneBurstReceive(connection: connection, finalToneSent: false, completion: completion)
            }))
            
        case .completion:
            print("\nGenerated final toneburst\n")
            toneBurstReceive(connection: connection, finalToneSent: true, completion: completion)
            
        case .failure:
            print("\nFailed to generate requested ToneBurst")
            completion(WhalesongError.generateFailure)
        }
    }
}
