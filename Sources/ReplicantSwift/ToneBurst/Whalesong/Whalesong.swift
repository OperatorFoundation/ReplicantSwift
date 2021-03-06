//
//  Whalesong.swift
//  ReplicantSwift
//
//  Created by Dr. Brandon Wiley on 2/21/19.
//

import Foundation
import Transport
#if os(Linux)
import NetworkLinux
#else
import Network
#endif

public class Whalesong: Codable
{
    /// Sequences that should be added to the outgoing packet stream.
    var addSequences: [SequenceModel]
    
    /// Sequences that should be removed from the incoming packet stream.
    var removeSequences: [SequenceModel]
    
    var addIndex = 0
    var removeIndex = 0
    var receiveBuffer = Data()
    
    public var nextRemoveSequenceLength: UInt?
    {
        get
        {
            guard removeIndex < removeSequences.count
                else
            {
                return nil
            }
            
            return removeSequences[removeIndex].length
        }
    }
    
    public init?(addSequences: [SequenceModel], removeSequences: [SequenceModel])
    {
        self.addSequences = addSequences
        self.removeSequences = removeSequences
    }
    
    
    /// With a Sequence model, generate a packet to inject into the stream.
    func makePacket(model: SequenceModel) -> Data?
    {
        var result = Data()
        
        // Add the Sequence
        result.append(model.sequence)
        
        // Add the bytes after the sequence
        if result.count < model.length
        {
            let length = Int(model.length) - result.count
            let randomBytes = generateRandomBytes(count: length)
            result.append(Data(randomBytes))
        }
        
        return result
    }
    
    func findRemoveSequenceInBuffer() -> MatchState
    {
        let sequenceModel = removeSequences[removeIndex]
        let sequence = sequenceModel.sequence
        
        if receiveBuffer.count >= sequenceModel.length
        {
            let source = Data(receiveBuffer[0 ..< sequence.count])
            if source.bytes == sequence.bytes
            {
                removeIndex += 1
                receiveBuffer = Data(receiveBuffer[sequenceModel.length...])
                return .success
            }
            else
            {
                return .failure
            }
        }
        else
        {
            return .insufficientData
        }
    }
    
    public func generate() -> SendState
    {
        guard addIndex < addSequences.count
            else
        {
            return .completion
        }
        
        guard let newPacket = makePacket(model: addSequences[addIndex])
            else
        {
            return .failure
        }
        
        addIndex += 1
        return .generating(newPacket)
    }
    
    public func remove(newData: Data) -> ReceiveState
    {
        guard let length = nextRemoveSequenceLength
            else
        {
            return .completion
        }
        
        guard newData.count == Int(length)
            else
        {
            return .failure
        }
        
        receiveBuffer.append(newData)
        
        switch findRemoveSequenceInBuffer()
        {
        case .success:
            if removeIndex == removeSequences.count
            {
                return .completion
            }
            else if removeIndex < removeSequences.count
            {
                return .receiving
            }
            else
            {
                return .failure
            }
        case .insufficientData:
            return .failure
        case .failure:
            return .failure
        }
    }
    
    func toneBurstSend(connection: Connection, completion: @escaping (Error?) -> Void)
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
    
    func toneBurstReceive(connection: Connection, finalToneSent: Bool, completion: @escaping (Error?) -> Void)
    {
        guard let toneLength = nextRemoveSequenceLength
            else
        {
            // Tone burst is finished
            return
        }
        
        connection.receive(minimumIncompleteLength: Int(toneLength), maximumLength: Int(toneLength) , completion:
            {
                (maybeToneResponseData, maybeToneResponseContext, connectionComplete, maybeToneResponseError) in
                
                guard maybeToneResponseError == nil
                    else
                {
                    print("\nReceived an error in the server tone response: \(maybeToneResponseError!)\n")
                    return
                }
                
                guard let toneResponseData = maybeToneResponseData
                    else
                {
                    print("\nTone response was empty.\n")
                    return
                }
                
                let receiveState = self.remove(newData: toneResponseData)
                
                switch receiveState
                {
                case .completion:
                    if !finalToneSent
                    {
                        self.toneBurstSend(connection: connection, completion: completion)
                    }
                    else
                    {
                        completion(nil)
                    }
                    
                case .receiving:
                    self.toneBurstSend(connection: connection, completion: completion)
                    
                case .failure:
                    print("\nTone burst remove failure.\n")
                    completion(WhalesongError.removeFailure)
                }
        })
    }
}
