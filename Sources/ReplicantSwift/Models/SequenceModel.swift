//
//  SequenceModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/15/18.
//

import Foundation

public struct SequenceModel
{
    /// Byte Sequence.
    var sequence: Data
    
    /// Target sequence Length.
    var length: UInt
    
    public init?(sequence: Data, length: UInt)
    {
        ///FIXME: Is this still correct? Length must be no larger than 1440 bytes
        if length == 0 || length > 65535
        {
            print("\nSequenceModel initialization failed: target length was either 0 or larger than 65535\n")
            return nil
        }
        
        self.sequence = sequence
        self.length = length
    }
}
