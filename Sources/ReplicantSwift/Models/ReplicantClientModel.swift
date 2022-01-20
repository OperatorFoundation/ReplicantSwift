import Foundation
import Logging

public struct ReplicantClientModel
{
    public let config: ReplicantConfig
    public let polish: Polish?
    public let toneBurst: ToneBurst?

    let log: Logger
    
    public init(withConfig config: ReplicantConfig, logger: Logger)
    {
        self.config = config
        self.log = logger
        
        if let polishConfig = config.polish
        {
            self.polish = polishConfig.getPolish(logger: logger)
        }
        else
        {
            self.polish = nil
        }
        
        if let toneBurst = config.toneBurst
        {
            self.toneBurst = toneBurst.getToneBurst()
        }
        else
        {
            self.toneBurst = nil
        }
    }
}

extension Data
{
    public var bytes: Array<UInt8>
    {
        return Array(self)
    }
}


