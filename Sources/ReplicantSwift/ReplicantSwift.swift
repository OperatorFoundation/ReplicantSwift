import Foundation
import Security
import CommonCrypto

public struct Replicant
{
    public let polish: Polish
    public var config: ReplicantConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantConfig)
    {
        guard let polish = Polish(serverPublicKey: config.serverPublicKey)
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

public struct ReplicantServer
{
    public var polish: Polish?
    public var config: ReplicantServerConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantServerConfig)
    {
        if let addSequences = config.addSequences, let removeSequences = config.removeSequences
        {
            self.toneBurst = ToneBurst(addSequences: addSequences, removeSequences: removeSequences)
        }
        
        self.config = config
    }
    
    public init?(withConfig config: ReplicantServerConfig, andPublicKey receiverPublicKey: SecKey)
    {
        guard let polish = Polish(serverPublicKey: receiverPublicKey)
            else
        {
            return nil
        }

        self.init(withConfig: config)
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
