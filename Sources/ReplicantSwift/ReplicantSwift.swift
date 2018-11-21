import Foundation
import Security
import CommonCrypto

public struct Replicant
{
    let encryptor = Encryption()
    
    var config: ReplicantConfig
    var serverPublicKey: SecKey
    var clientPublicKey: SecKey
    var clientPrivateKey: SecKey
    
    var toneBurst: ToneBurst?
    
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
