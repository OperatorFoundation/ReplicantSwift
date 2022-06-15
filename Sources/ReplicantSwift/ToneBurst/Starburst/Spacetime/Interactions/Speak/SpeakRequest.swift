//
//  SpeakRequest.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Foundation
import Spacetime
import Universe

public class SpeakRequest: Effect
{
    let universe: Universe
    let uuid: UUID
    let speak: Speak

    public override var description: String
    {
        return "\(self.module).SpeakRequest[id: \(self.id), uuid: \(self.uuid), speak: \(speak.description)]"
    }

    public init(universe: Universe, uuid: UUID, speak: Speak)
    {
        self.universe = universe
        self.uuid = uuid
        self.speak = speak

        super.init(module: StarburstModule.name)
    }
}
