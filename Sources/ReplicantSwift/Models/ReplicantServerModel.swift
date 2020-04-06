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
    public var polish: SilverServerModel
    public var config: ReplicantServerConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantServerConfig, logQueue: Queue<String>)
    {
        guard let polish = SilverServerModel(salt: config.salt, logQueue: logQueue)
        else
        {
            return nil
        }
        
        if let toneBurst = config.toneBurst
        {
            self.toneBurst = toneBurst.getToneBurst()
        }
        
        self.config = config
        self.polish = polish
    }
}
