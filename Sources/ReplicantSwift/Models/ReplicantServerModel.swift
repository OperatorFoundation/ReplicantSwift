//
//  ReplicantServerModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation

public struct ReplicantServerModel
{
    public var polish: PolishServerModel
    public var config: ReplicantServerConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantServerConfig)
    {
        guard let polish = PolishServerModel()
            else
        {
            return nil
        }
        
        if let addSequences = config.addSequences, let removeSequences = config.removeSequences
        {
            self.toneBurst = ToneBurst(addSequences: addSequences, removeSequences: removeSequences)
        }
        
        self.config = config
        self.polish = polish
    }
}
