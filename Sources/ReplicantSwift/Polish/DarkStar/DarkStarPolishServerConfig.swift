//
//  DarkStarServerConfig.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import Logging

public struct DarkStarPolishServerConfig: Polish, Codable
{
    public let serverPrivateKey: Data
    public let chunkSize: UInt16
    public let chunkTimeout: Int

    public func construct(logger: Logger) -> PolishServer?
    {
        return DarkStarPolishServer(logger: logger, chunkSize: chunkSize, chunkTimeout: chunkTimeout)
    }
}
