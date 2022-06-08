//
//  WaitResponse.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime

public class WaitResponse: Event
{
    public override var description: String
    {
        return "\(self.module).WaitResponse[effectID: \(String(describing: self.effectId))]"
    }

    public init(_ effectId: UUID)
    {
        super.init(effectId, module: StarburstModule.name)
    }
}
