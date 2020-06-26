import Foundation
import Security
import CommonCrypto
import SwiftQueue

public struct ReplicantClientModel
{
    public let config: ReplicantConfig<SilverClientConfig>
    public let polish: PolishConnection?
    public let toneBurst: ToneBurst?
    
    public init(withConfig config: ReplicantConfig<SilverClientConfig>, logQueue: Queue<String>)
    {
        self.config = config
        
        if let polishConfig = config.polish
        {
            self.polish = polishConfig.construct(logQueue: logQueue)
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
