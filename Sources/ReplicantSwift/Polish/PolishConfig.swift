//
//  SupportedPolishes.swift
//  ReplicantSwift
//
//  Created by Mafalda on 4/28/20.
//

import Foundation
import Logging

struct testCodable<T>: Codable where T: TestProtocol
{
    var words: String
    var testPro: T
}

protocol TestProtocol: Codable
{
    func testFunction()
}

//public protocol PolishClientConfig: Codable
//{
//    func construct(logger: Logger) -> PolishConnection?
//}
//
//public protocol PolishServerConfig: Codable
//{
//    func construct(logger: Logger) -> PolishServer?
//}

