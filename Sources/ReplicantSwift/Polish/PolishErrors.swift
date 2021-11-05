//
//  PolishErrors.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation

enum HandshakeError: Error
{
    case publicKeyDataGenerationFailure
    case noClientKeyData
    case invalidClientKeyData
    case missingClientKey
    case clientKeyDataIncorrectSize
    case unableToDecryptData
    case dataCreationError
    case writeError
}
