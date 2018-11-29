import XCTest
import Foundation

@testable import ReplicantSwift

final class ReplicantSwiftTests: XCTestCase
{
    var polish: Polish!
    let attributes: [String: Any] =
        [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
         kSecAttrKeySizeInBits as String: 256,
         kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: true,
                                         kSecAttrApplicationTag as String: "com.example.keys.mykey".data(using: .utf8)!]
    ]
    
    override func setUp()
    {
        super.setUp()
        
        // Generate private key
        var error: Unmanaged<CFError>?
        guard let bobPrivate = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else
        {
            print(error!)
            XCTFail()
            return
        }
        
        // Generate public key
        let bobPublic = SecKeyCopyPublicKey(bobPrivate)!
        
        polish = Polish(serverPublicKey: bobPublic)!
        
    }
    
    // MARK: Polish Tests
    
    func testGeneratePrivateUsingPublic()
    {
        guard let privateKey = Polish.generatePrivateKey()
        else
        {
            XCTFail()
            return
        }
        
        let maybePuplicKey = Polish.generatePublicKey(usingPrivateKey: privateKey)
        XCTAssertNotNil(maybePuplicKey)
    }
    
    func testDecodeKeyFromData()
    {
        guard let privateKey = Polish.generatePrivateKey()
            else
        {
            XCTFail()
            return
        }
        
        guard let alicePuplicKey = Polish.generatePublicKey(usingPrivateKey: privateKey)
        else
        {
            print("\nUnable to generate publicKeyData from private key.\n")
            XCTFail()
            return
        }
        
        var error: Unmanaged<CFError>?
        
        // Encode public key as data
        guard let keyData = SecKeyCopyExternalRepresentation(alicePuplicKey, &error) as Data?
        else
        {
            XCTFail()
            return
        }
        
        guard let decodedKey = Polish.decodeKey(fromData: keyData)
        else
        {
            XCTFail()
            return
        }
        
        XCTAssertTrue(compare(secKey1: decodedKey, secKey2: alicePuplicKey))
    }
    
    func compare(secKey1: SecKey, secKey2: SecKey) -> Bool
    {
        var error: Unmanaged<CFError>?
        
        guard let secKey1Data = SecKeyCopyExternalRepresentation(secKey1, &error) as Data?
        else
        {
            return false
        }
        
        guard let secKey2Data = SecKeyCopyExternalRepresentation(secKey2, &error) as Data?
            else
        {
            return false
        }
        
        if secKey1Data == secKey2Data
        {
            return true
        }
        else
        {
            return false
        }
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
        let maybeCipherText = polish.encrypt(payload: plainText, usingServerKey: bobPublic)
        
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
        guard let cipherText = polish.encrypt(payload: plainText, usingServerKey: bobPublic)
        else
        {
            XCTFail()
            return
        }
        
        guard let maybeDecoded = polish.decrypt(payload: cipherText, usingPrivateKey: bobPrivate)
        else
        {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(maybeDecoded)
        XCTAssertEqual(maybeDecoded, plainText)
    }
    
    
    // MARK: ToneBurst
    
    let sequence1 = Data(string: "OH HELLO")
    let sequence2 = Data(string: "You say hello, and I say goodbye.")
    let sequence3 = Data(string: "I don't know why you say 'Goodbye', I say 'Hello'.")
    
    func testToneBurstInit()
    {
        let sequence = SequenceModel(sequence: sequence1, length: 256)!
        let toneBurst = ToneBurst(addSequences: [sequence], removeSequences: [sequence])
        XCTAssertNotNil(toneBurst)
    }
    
    func testFindMatchingPacket()
    {
        let sequence = SequenceModel(sequence: sequence1, length: 256)!
        guard let toneBurst = ToneBurst(addSequences: [sequence], removeSequences: [sequence])
        else
        {
            XCTFail()
            return
        }
        
        _ = toneBurst.generate()
        
        // Fill the buffer
        let randomBytes = Data(repeating: 0, count: 256)
        toneBurst.receiveBuffer.append(sequence1)
        toneBurst.receiveBuffer.append(randomBytes)
        
        let matchState = toneBurst.findRemoveSequenceInBuffer()
        XCTAssertTrue(matchState == .success)
        switch matchState
        {
        case .success:
            print("\nRemove sequence found!\n")
        case .failure:
            print("\nFailed to find remove sequence.\n")
            XCTFail()
        case .insufficientData:
            print("\nBuffer was smaller than the remove sequence we were looking for.\n")
            XCTFail()
        }
    }
    
    func testOneSequence()
    {
        let sequence = SequenceModel(sequence: sequence1, length: 256)!
        guard let toneBurst = ToneBurst(addSequences: [sequence], removeSequences: [sequence])
            else
        {
            XCTFail()
            return
        }
        
        let transformState = toneBurst.generate()
        
        switch transformState
        {
            case .failure:
                XCTFail()
                return
            
            case .generating(let transformResult):
                let restoreState = toneBurst.remove(newData: transformResult)
                print("\nBuffer to transform: \n \(sequence1)\n")
                print("\nTransform Result: \n \(transformResult)\n")
                
                switch restoreState
                {
                case .completion:
                    print("\nRestore Result: Complete\n")
                default:
                    print("\nRestore Result: \(restoreState)\n")
                    XCTFail()
                }
            
            case .completion:
                print("\nTransform Complete\n")
        }
    }
}
