import XCTest
@testable import ReplicantSwift

final class ReplicantSwiftTests: XCTestCase
{
    let encryptor = Encryption()
    let attributes: [String: Any] =
        [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
         kSecAttrKeySizeInBits as String: 256,
         kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: true,
                                         kSecAttrApplicationTag as String: "com.example.keys.mykey".data(using: .utf8)!]
    ]
    
    // MARK: Encryption Tests
    
//    func testInitEncryptionNoKey()
//    {
//        let maybeEncryptor = Encryption(withPrivateKey: nil)
//        XCTAssertNotNil(maybeEncryptor)
//    }
    
    func testGeneratePrivateUsingPublic()
    {
        guard let privateKey = encryptor.generatePrivateKey()
        else
        {
            XCTFail()
            return
        }
        
        let maybePuplicKey = encryptor.generatePublicKey(usingPrivateKey: privateKey)
        XCTAssertNotNil(maybePuplicKey)
    }
    
    func testDecodeKeyFromData()
    {
        guard let privateKey = encryptor.generatePrivateKey()
            else
        {
            XCTFail()
            return
        }
        
        guard let alicePuplicKeyData = encryptor.generatePublicKey(usingPrivateKey: privateKey)
        else
        {
            print("\nUnable to generate publicKeyData from private key.\n")
            XCTFail()
            return
        }
        
        let alicePublicKey = Encryption.decodeKey(fromData: alicePuplicKeyData)
        XCTAssertNotNil(alicePublicKey)
    }
    
    func testEncryptData()
    {
        var error: Unmanaged<CFError>?
        
        // Generate private key
        guard let bobPrivate = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else
        {
            print(error!)
            XCTFail()
            return
        }
        
        // Generate public key
        let bobPublic = SecKeyCopyPublicKey(bobPrivate)!
        
        let plainText = Data(repeating: 0x0A, count: 4096)
        
        // Encrypt Plain Text
        let maybeCipherText = encryptor.encrypt(payload: plainText, usingServerKey: bobPublic)
        
        XCTAssertNotNil(maybeCipherText)
        XCTAssertNotEqual(maybeCipherText!, plainText)
    }
    
    func testDecryptData()
    {
        var error: Unmanaged<CFError>?
        
        // Generate private key
        guard let bobPrivate = SecKeyCreateRandomKey(attributes as CFDictionary, &error)
        else
        {
            print(error!)
            XCTFail()
            return
        }
        
        // Generate public key
        let bobPublic = SecKeyCopyPublicKey(bobPrivate)!
        
        let plainText = Data(repeating: 0x0A, count: 4096)
        guard let cipherText = encryptor.encrypt(payload: plainText, usingServerKey: bobPublic)
        else
        {
            XCTFail()
            return
        }
        
        guard let maybeDecoded = encryptor.decrypt(payload: cipherText, usingPrivateKey: bobPrivate)
        else
        {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(maybeDecoded)
        XCTAssertEqual(maybeDecoded, plainText)
    }
    
    // MARK: CryptoHandshake
    
    func testHandshakeInit()
    {
        var error: Unmanaged<CFError>?

        // Generate private server key
        guard let bobPrivate = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else
        {
            print(error!)
            XCTFail()
            return
        }
        
        // Generate public server key
        let bobPublic = SecKeyCopyPublicKey(bobPrivate)!
        
        // Encode public key as data
        guard let bobPublicData = SecKeyCopyExternalRepresentation(bobPublic, &error) as Data? else
        {
            print("\n\(error!.takeRetainedValue())\n")
            XCTFail()
            return
        }

        // Generate private key
        guard let alicePrivate = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else
        {
            print(error!)
            XCTFail()
            return
        }
        
        // Generate public key
        let alicePublic = SecKeyCopyPublicKey(alicePrivate)!
        
        let cryptoHandshake = CryptoHandshake(withKey: alicePublic, andServerKeyData: bobPublicData)
        
        XCTAssertNotNil(cryptoHandshake)
    }
    
    
}
