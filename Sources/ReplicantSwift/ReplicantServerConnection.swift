//
//  ReplicantServerConnection.swift
//  Replicant
//
//  Created by Adelita Schule on 12/3/18.
//  MIT License
//
//  Copyright (c) 2020 Operator Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Dispatch
import Logging

import Transmission
import Net
import Chord

open class ReplicantServerConnection: ReplicantBaseConnection
{
    public var replicantConfig: ReplicantServerConfig
    public var replicantServerModel: ReplicantServerModel
    
    // FIXME: Unencrypted chunk size for non-polish instances
    var sendMessageQueue = DispatchQueue(label: "ReplicantServerConnection.sendMessageQueue")
    var wasReady = false
    
    public init?(connection: Transmission.Connection,
                 parameters: NWParameters,
                 replicantConfig: ReplicantServerConfig,
                 logger: Logger)
    {
        guard let newReplicant = ReplicantServerModel(withConfig: replicantConfig, logger: logger) else {
            logger.error("failed to initialize ReplicantServerModel")
            return nil
        }

        self.replicantConfig = replicantConfig
        self.replicantServerModel = newReplicant
        
        super.init(log: logger, network: connection)
        
        if let polishConnection = replicantServerModel.polish
        {
            self.unencryptedChunkSize = polishConnection.chunkSize - UInt16(payloadLengthOverhead)
        }

        let maybeIntroError = Synchronizer.sync(introductions)
        
        guard maybeIntroError == nil
        else
        {
            logger.error("Error attempting to meet the server during Replicant Connection Init.")
            return
        }
    }
}
