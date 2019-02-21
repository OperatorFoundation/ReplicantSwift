//
//  WhalesongState.swift
//  ReplicantSwift
//
//  Created by Dr. Brandon Wiley on 2/21/19.
//

import Foundation

public enum ReceiveState
{
    case receiving
    case completion
    case failure
}

public enum SendState
{
    case generating(Data)
    case completion
    case failure
}

enum MatchState
{
    case insufficientData
    case success
    case failure
}

enum WhalesongError: Error
{
    case generateFailure
    case removeFailure
}
