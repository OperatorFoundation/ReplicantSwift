//
//  SupportedPolishes.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import SwiftQueue


struct testCodable<T>: Codable where T: TestProtocol
{
    var words: String
    var testPro: T
}

protocol TestProtocol: Codable
{
    func testFunction()
}



public protocol PolishClientConfig: Codable
{
    func construct(logQueue: Queue<String>) -> PolishConnection?
}

public protocol PolishServerConfig: Codable
{
    func construct(logQueue: Queue<String>) -> PolishServer?
}

