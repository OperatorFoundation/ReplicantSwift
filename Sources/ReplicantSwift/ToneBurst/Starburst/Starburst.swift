//
//  Starburst.swift
//  
//
//  Created by Dr. Brandon Wiley on 5/9/22.
//

import Foundation

import Ghostwriter
import Transmission

public class Starburst: Codable, ToneBurst
{
    let config: StarburstConfig
    var listening = false

    public init(_ config: StarburstConfig)
    {
        self.config = config
    }

    public func perform(connection: Transmission.Connection) throws
    {
//        for moment in config.moments
//        {
//            switch moment
//            {
//                case .speak(let speak):
//                    self.handleSpeak(speak)
//
//                case .listen(let listen):
//                    self.handleListen(listen)
//
//                case .wait(let wait):
//                    self.handleWait(wait)
//            }
//        }
    }

    func handleSpeak(_ speak: Speak)
    {

    }

    func handleListen(_ listen: Listen)
    {

    }

    func handleWait(_ wait: Wait)
    {
        Thread.sleep(forTimeInterval: wait.interval)
    }
}

public enum StarburstError: Error
{
    case timeout
    case connectionClosed
}
