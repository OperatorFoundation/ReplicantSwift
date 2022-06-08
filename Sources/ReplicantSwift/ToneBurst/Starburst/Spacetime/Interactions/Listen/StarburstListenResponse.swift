//
//  StarburstListenResponse.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Spacetime

public class StarburstListenResponse: Event
{
    let result: StarburstListenResult

    public override var description: String
    {
        return "\(self.module).StarburstListenResponse[effectID: \(String(describing: self.effectId)), result: \(self.result)]"
    }

    public init(_ effectId: UUID, _ result: StarburstListenResult)
    {
        self.result = result

        super.init(effectId, module: StarburstModule.name)
    }
}
