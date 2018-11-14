//
//  Constants.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation

let chunkSize = 4096
let aesOverhead = 81
let bufferSize = chunkSize - aesOverhead
let keySize = 64
let keyDataSize = keySize + 1
let cryptoHandshakeSize = chunkSize
let cryptoHandshakePaddingSize = cryptoHandshakeSize - keySize
let responseSize = chunkSize
