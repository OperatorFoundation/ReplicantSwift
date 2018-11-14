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
    
    /// Index of the first packet to be injected into the stream.
    var firstIndex: UInt
    
    /// Index of the last packet to be injected into the stream.
    var lastIndex: UInt
    
    /// Current Index into the output stream.
    /// This starts at zero and is incremented every time a packet is output.
    /// The OutputIndex is compared to the SequenceModel Index.
    /// When they are equal, a byte Sequence packet is injected into the output.
    var outputIndex: UInt
    
    public init?(addSequences: [SequenceModel], removeSequences: [SequenceModel])
    {
        guard let firstSequence = addSequences.first
            else
        {
            return nil
        }
        
        guard let lastSequence = addSequences.last
            else
        {
            return nil
        }

        // Check to make sure that add sequences do not have the same indices, do the same for remove sequences
        let addSeqGroupedByIndex = Dictionary(grouping: addSequences) { $0.index }
        for index in addSeqGroupedByIndex
        {
            if index.value.count > 1
            {
                return nil
            }
        }
        
        let removeSeqGroupedByIndex = Dictionary(grouping: removeSequences) { $0.index }
        for index in removeSeqGroupedByIndex
        {
            if index.value.count > 1
            {
                return nil
            }
        }
        
        self.addSequences = addSequences
        self.removeSequences = removeSequences
        self.firstIndex = firstSequence.index
        self.lastIndex = lastSequence.index
        self.outputIndex = 0
    }
    
    /// Inject packets
    func inject(results: [Data]) -> [Data]
    {
        var nextPacket = addSequences.first(where: {(sequence) in sequence.index == outputIndex})
        var newResults = results
        
        while nextPacket != nil
        {
            guard let newPacket = makePacket(model: nextPacket!)
                else
            {
                break
            }
            
            newResults.append(newPacket)
            outputIndex += 1
            nextPacket = addSequences.first(where: {(sequence) in sequence.index == outputIndex})
        }
        
        return newResults
    }
    
    /// With a Sequence model, generate a packet to inject into the stream.
    func makePacket(model: SequenceModel) -> Data?
    {
        var result = Data()
        
//        // Add the bytes before the Sequence.
//        if model.offset > 0
//        {
//            var randomBytes = [UInt8](repeating: 0, count: Int(model.offset))
//            let status = SecRandomCopyBytes(kSecRandomDefault, Int(model.offset), &randomBytes)
//            if status == errSecSuccess
//            {
//                result.append(Data(bytes: randomBytes))
//            }
//            else
//            {
//                return nil
//            }
//        }
        
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
    
    /// For a byte Sequence, see if there is a matching Sequence to remove.
    func findMatchingPacket(sequence: Data) -> Bool
    {
        for index in 0 ..< removeSequences.count
        {
            let sequenceModel = removeSequences[index]
//            let index1 = Int(sequenceModel.offset)
//            let index2 = index1 + sequenceModel.sequence.count
            
            if sequence.count >= sequenceModel.sequence.count
            {
                //let source = Data(sequence[index1 ..< index2])
                
                //if source.bytes == sequenceModel.sequence.bytes
                if sequence == sequenceModel.sequence
                {
                    //Remove matched packet so that it's not matched again
                    removeSequences.remove(at: index)
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    /// Inject header.
    public func transform(buffer: Data) -> [Data]
    {
        var results: [Data] = []
        
        // Check if the current Index into the packet stream is within the range where a packet injection could possibly occur.
        if outputIndex <= lastIndex
        {
            // Injection has not finished, but may not have started yet.
            if Int(outputIndex) >= Int(firstIndex) - 1
            {
                // Injection has started and has not finished, so check to see if it is time to inject a packet.
                // Inject fake packets before the real packet
                results = inject(results: results)
                
                // Inject the real packet
                results.append(buffer)
                outputIndex += 1
                
                //Inject fake packets after the real packet
                results = inject(results: results)
            }
            else
            {
                // Injection has not started yet. Keep track of the Index.
                results = [buffer]
                outputIndex += 1
            }
            
            return results
        }
        else
        {
            // Injection has finished and will not occur again. Take the fast path and just return the buffer.
            return [buffer]
        }
    }
    
    /// Remove injected packets.
    public func restore(buffer: Data) -> [Data]
    {
        if findMatchingPacket(sequence: buffer)
        {
            return []
        }
        else
        {
            return [buffer]
        }
    }
    
}

public struct SequenceModel
{
    /// Index of the packet into the stream.
    var index: UInt
    
    /// Byte Sequence.
    var sequence: Data
    
    /// Target sequence Length.
    var length: UInt
    
    init?(index: UInt, offset: UInt, sequence: Data, length: UInt)
    {
        ///Length must be no larger than 1440 bytes
        if length == 0 || length > 1440
        {
            print("\nByteSequenceShaper initialization failed: target length was either 0 or larger than 1440\n")
            return nil
        }
        
        self.index = index
        self.sequence = sequence
        self.length = length
    }
}
