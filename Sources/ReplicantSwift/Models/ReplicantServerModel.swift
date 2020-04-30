//
//  ReplicantServerModel.swift
//  ReplicantSwift
//
//  Created by Adelita Schule on 12/18/18.
//

import Foundation
import SwiftQueue

public struct ReplicantServerModel
{
    public var polish: SilverServer?
    public var config: ReplicantServerConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantServerConfig, logQueue: Queue<String>)
    {
        if let polishConfig = config.polish as? SilverServerConfig,
            let silverServer = polishConfig.construct(logQueue: logQueue) as? SilverServer
        {
            self.polish = silverServer
        }
        
        if let toneBurst = config.toneBurst
        {
            self.toneBurst = toneBurst.getToneBurst()
        }
        
        self.config = config
    }
}
