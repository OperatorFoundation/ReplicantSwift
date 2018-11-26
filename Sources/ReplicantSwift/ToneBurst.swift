//
//  ToneBurst.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation
import Datable

/// Injects byte sequences into a stream of bytes
public class ToneBurst: NSObject
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
            
            var randomBytes = [UInt8](repeating: 0, count: length)
            let status = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
            if status == errSecSuccess
            {
                result.append(Data(bytes: randomBytes))
            }
            else
            {
                return nil
            }
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
            return .failure
        }

        guard let newPacket = makePacket(model: addSequences[addIndex])
        else
        {
            return .failure
        }
        
        addIndex += 1
        
        if addIndex == addSequences.count
        {
            return .completion(newPacket)
        }
        else
        {
            return .generating(newPacket)
        }
    }
    
    public func remove(newData: Data) -> ReceiveState
    {
        receiveBuffer.append(newData)
        
        switch findRemoveSequenceInBuffer()
        {
            case .success:
                if removeIndex == removeSequences.count
                {
                    return .completion(receiveBuffer)
                }
                else if removeIndex < removeSequences.count
                {
                    return .waiting
                }
                else
                {
                    return .failure
                }
            case .insufficientData:
                return .waiting
            case .failure:
                return .failure
        }
    }
    
}

public enum ReceiveState
{
    case waiting
    case completion(Data)
    case failure
}

public enum SendState
{
    case generating(Data)
    case completion(Data)
    case failure
}

enum MatchState
{
    case insufficientData
    case success
    case failure
}
