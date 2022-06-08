//
//  SpeakResponse.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime

public class SpeakResponse: Event
{
    public override var description: String
    {
        return "\(self.module).SpeakResonse[effectID: \(String(describing: self.effectId))]"
    }

    public init(_ effectId: UUID)
    {
        super.init(effectId, module: StarburstModule.name)
    }
}
