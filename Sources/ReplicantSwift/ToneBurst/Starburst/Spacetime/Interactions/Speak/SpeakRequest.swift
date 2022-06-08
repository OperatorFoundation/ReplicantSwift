//
//  SpeakRequest.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Foundation
import Spacetime

public class SpeakRequest: Effect
{
    let speak: Speak

    public override var description: String
    {
        return "\(self.module).SpeakRequest[id: \(self.id), speak: \(speak.description)]"
    }

    public init(_ speak: Speak)
    {
        self.speak = speak

        super.init(module: StarburstModule.name)
    }
}
