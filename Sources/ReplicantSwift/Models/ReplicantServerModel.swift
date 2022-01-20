//
//  ReplicantServerModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation
import Logging

public struct ReplicantServerModel
{
    public var polish: Polish?
    public var config: ReplicantServerConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantServerConfig, logger: Logger)
    {
        if let polishConfig = config.polish
        {
            self.polish = polishConfig.getPolish(logger: logger)
        }
        
        if let toneBurst = config.toneBurst
        {
            self.toneBurst = toneBurst.getToneBurst()
        }
        
        self.config = config
    }
}
