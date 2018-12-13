//
//  ReplicantConfig.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/14/18.
//

import Foundation

public struct ReplicantConfig: Codable
{
    public var serverPublicKey: Data
    public var chunkSize: Int
    public var chunkTimeout: Int
    public var addSequences: [SequenceModel]?
    public var removeSequences: [SequenceModel]?
    
    
    public init?(serverPublicKey: Data, chunkSize: Int, chunkTimeout: Int, addSequences: [SequenceModel]?, removeSequences: [SequenceModel]?)
    {
        guard chunkSize >= keySize + aesOverheadSize
        else
        {
            print("\nUnable to initialize ReplicantConfig: chunkSize (\(chunkSize)) cannot be smaller than keySize + aesOverheadSize (\(keySize + aesOverheadSize))\n")
            return nil
        }
        self.serverPublicKey = serverPublicKey
        self.chunkSize = chunkSize
        self.chunkTimeout = chunkTimeout
        self.addSequences = addSequences
        self.removeSequences = removeSequences
    }
}
