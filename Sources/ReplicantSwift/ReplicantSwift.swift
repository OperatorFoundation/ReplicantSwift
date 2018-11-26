import Foundation
import Security
import CommonCrypto

public struct Replicant
{
    public let encryptor: Encryption
    public var config: ReplicantConfig
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantConfig)
    {
        guard let encryption = Encryption(serverPublicKey: config.serverPublicKey)
        else
        {
            return nil
        }
        
        if let addSequences = config.addSequences, let removeSequences = config.removeSequences
        {
            self.toneBurst = ToneBurst(addSequences: addSequences, removeSequences: removeSequences)
        }
        
        self.config = config
        self.encryptor = encryption
    }
}

extension Data
{
    public var bytes: Array<UInt8>
    {
        return Array(self)
    }
}
