import Foundation
import Security
import CommonCrypto

public struct Replicant
{
    public let encryptor = Encryption()
    
    public var config: ReplicantConfig
    public var serverPublicKey: SecKey
    public var clientPublicKey: SecKey
    public var clientPrivateKey: SecKey
    public var toneBurst: ToneBurst?
    
    public init?(withConfig config: ReplicantConfig)
    {
        guard let keyPair = encryptor.generateKeyPair()
        else
        {
            return nil
        }
        
        if let addSequences = config.addSequences, let removeSequences = config.removeSequences
        {
            self.toneBurst = ToneBurst(addSequences: addSequences, removeSequences: removeSequences)
        }
        
        self.config = config
        self.serverPublicKey = config.serverPublicKey
        self.clientPublicKey = keyPair.publicKey
        self.clientPrivateKey = keyPair.privateKey
    }
}

extension Data
{
    public var bytes: Array<UInt8>
    {
        return Array(self)
    }
}
