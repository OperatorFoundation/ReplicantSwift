//
//  StarburstListenRequest.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime
import Universe

public class StarburstListenRequest: Effect
{
    public let universe: Universe
    public let uuid: UUID
    public let listen: Listen

    public override var description: String
    {
        return "\(self.module).StarburstListenRequest[id: \(self.id), listen: \(self.listen)]"
    }

    public init(_ universe: Universe, _ uuid: UUID, _ listen: Listen)
    {
        self.universe = universe
        self.uuid = uuid
        self.listen = listen

        super.init(module: StarburstModule.name)
    }
}
