//
//  WaitRequest.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime

public class WaitRequest: Effect
{
    let interval: TimeInterval

    public override var description: String
    {
        return "\(self.module).WaitRequest[id: \(self.id), interval: \(self.interval)]"
    }

    public init(_ interval: TimeInterval)
    {
        self.interval = interval

        super.init(module: StarburstModule.name)
    }
}
