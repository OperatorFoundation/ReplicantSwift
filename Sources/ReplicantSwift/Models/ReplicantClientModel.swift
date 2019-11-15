import Foundation
import Security
import CommonCrypto
import SwiftQueue

public struct ReplicantClientModel
{
    public let polish: ChromeClientModel
    public var config: ReplicantConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantConfig, logQueue: Queue<String>)
    {
        guard let polish = ChromeClientModel(serverPublicKeyData: config.serverPublicKey, logQueue: logQueue)
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

extension Data
{
    public var bytes: Array<UInt8>
    {
        return Array(self)
    }
}
