//
//  StarburstListenRequest.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime

public class StarburstListenRequest: Effect
{
    public let listen: Listen

    public override var description: String
    {
        return "\(self.module).StarburstListenRequest[id: \(self.id), listen: \(self.listen)]"
    }

    public init(_ listen: Listen)
    {
        self.listen = listen

        super.init(module: StarburstModule.name)
    }
}
