//
//  SupportedPolishes.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import SwiftQueue

public protocol PolishClientConfig
{
    func construct(logQueue: Queue<String>) -> PolishConnection?
}

public protocol PolishServerConfig
{
    func construct(logQueue: Queue<String>) -> PolishServer?
}

