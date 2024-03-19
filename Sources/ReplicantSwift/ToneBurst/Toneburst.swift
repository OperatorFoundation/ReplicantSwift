//
//  ToneBurst.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 11/9/18.
//

import Foundation
import Datable
import TransmissionAsync

/// Injects byte sequences into a stream of bytes
open class ToneBurst: Codable
{
    open func perform(connection: TransmissionAsync.AsyncConnection) async throws
    {
        throw ReplicantError.unimplemented
    }
}
