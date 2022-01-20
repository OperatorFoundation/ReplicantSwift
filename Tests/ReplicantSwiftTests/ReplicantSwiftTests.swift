import XCTest
import Foundation
import Datable
import SwiftQueue

@testable import ReplicantSwift

final class ReplicantSwiftTests: XCTestCase
{
    
//    let logQueue = Queue<String>()
//    var polishClientModel: SilverClientConnection!
//    var polishController: SilverController!
//    var attributes: CFDictionary!
////    let attributes: [String: Any] =
////        [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
////         kSecAttrKeySizeInBits as String: 256,
////         kSecPrivateKeyAttrs as String: [kSecAttrIsPermanent as String: true,
////                                         kSecAttrApplicationTag as String: "com.example.keys.mykey".data(using: .utf8)!]
////    ]
//
//    override func setUp()
//    {
//        super.setUp()
//
//        polishController = SilverController(logger: logQueue)
//        attributes = polishController.generateClientKeyAttributesDictionary()
//
//        // Generate private key
//        let bobPrivate = P256.KeyAgreement.PrivateKey()
//
//        // Encode key as data
//        let keyData = bobPrivate.publicKey.x963Representation
//
//        guard let clientModel = SilverClientConnection(logger: logQueue, serverPublicKeyData: keyData, chunkSize: 1440, chunkTimeout: 1000)
//        else
//        {
//            return
//        }
//
//        polishClientModel = clientModel
//    }
//
//    // MARK: Polish Tests
//
//    func testFetchOrCreateServerKey()
//    {
//        let controller = SilverController(logQueue: logQueue)
//
//        // Ask for the keypair and accept either the existing key or a new one
//        guard let _ = controller.fetchOrCreateServerKeyPair()
//        else
//        {
//            XCTFail()
//            return
//        }
//
//        // Delete the existing key
//        let query = controller.generateServerKeySearchQuery(withLabel: controller.serverKeyLabel)
//        let deleteStatus = SecItemDelete(query as CFDictionary)
//
//        switch deleteStatus
//        {
//        case errSecItemNotFound:
//            print("Could not find a server key to delete.\n")
//            XCTFail()
//            return
//        case noErr:
//            print("Deleted client keys.\n")
//        default:
//            print("Unexpected status: \(deleteStatus.description)\n")
//            XCTFail()
//            return
//        }
//
//        // Ask for keys again
//        guard let _ = controller.fetchOrCreateServerKeyPair()
//            else
//        {
//            XCTFail()
//            return
//        }
//
//        // Clean up, delete the existing key
//        let cleanUpStatus = SecItemDelete(query)
//
//        switch cleanUpStatus
//        {
//        case errSecItemNotFound:
//            print("Could not find a client key to delete.\n")
//            XCTFail()
//            return
//        case noErr:
//            print("Deleted client keys.\n")
//        default:
//            print("Unexpected status: \(deleteStatus.description)\n")
//            XCTFail()
//            return
//        }
//    }
//
//    func testDecodeProvidedKey()
//    {
//
//        let providedKeyString = "BMfps8ZfYYvIdU2eSNsbHJfYnFKGgtlTK3Osyqo/BHOP8Djzkxk03SHD8auOFhI4PxfrhSeIQ8q8JDNJOy+2ulQ="
//
//        guard let providedKeyData = Data(base64Encoded: providedKeyString)
//        else
//        {
//            XCTFail()
//            return
//        }
//
//        let decodedKey = polishClientModel.controller.decodeKey(fromData: providedKeyData)
//        XCTAssertNotNil(decodedKey)
//    }
//
//    func compare(secKey1: SecKey, secKey2: SecKey) -> Bool
//    {
//        var error: Unmanaged<CFError>?
//
//        guard let secKey1Data = SecKeyCopyExternalRepresentation(secKey1, &error) as Data?
//        else
//        {
//            return false
//        }
//
//        guard let secKey2Data = SecKeyCopyExternalRepresentation(secKey2, &error) as Data?
//            else
//        {
//            return false
//        }
//
//        if secKey1Data == secKey2Data
//        {
//            return true
//        }
//        else
//        {
//            return false
//        }
//    }
//
//    func testDecryptData()
//    {
//        let plainText = Data(repeating: 0x0A, count: 4096)
//
//        let key = SymmetricKey(size: SymmetricKeySize(bitCount: 256))
//
//        guard let cipherText = polishClientModel.controller.encrypt(payload: plainText, symmetricKey: key)
//        else
//        {
//            XCTFail()
//            return
//        }
//
//        guard let maybeDecrypted = polishClientModel.controller.decrypt(payload: cipherText, symmetricKey: key)
//        else
//        {
//            XCTFail()
//            return
//        }
//
//        XCTAssertNotNil(maybeDecrypted)
//        XCTAssertEqual(maybeDecrypted.bytes, plainText.bytes)
//    }
//
    // MARK: ToneBurst
    let sequence1 = Data(string: "OH HELLO")
    let sequence2 = Data(string: "You say hello, and I say goodbye.")
    let sequence3 = Data(string: "I don't know why you say 'Goodbye', I say 'Hello'.")

    func testToneBurstInit()
    {
        let sequence = SequenceModel(sequence: sequence1, length: 256)!
        let toneBurst = Whalesong(addSequences: [sequence], removeSequences: [sequence])
        XCTAssertNotNil(toneBurst)
    }
    
    func testMonolith()
    {
        let sequence = SequenceModel(sequence: sequence1, length: 256)!
        let monotoneConfig = MonotoneConfig(addSequences: [sequence], removeSequences: [sequence])
        XCTAssertNotNil(monotoneConfig)
    }
//
//    func testFindMatchingPacket()
//    {
//        let sequence = SequenceModel(sequence: sequence1, length: 256)!
//        guard let toneBurst = Whalesong(addSequences: [sequence], removeSequences: [sequence])
//        else
//        {
//            XCTFail()
//            return
//        }
//
//        _ = toneBurst.generate()
//
//        // Fill the buffer
//        let randomBytes = Data(repeating: 0, count: 256)
//        toneBurst.receiveBuffer.append(sequence1)
//        toneBurst.receiveBuffer.append(randomBytes)
//
//        let matchState = toneBurst.findRemoveSequenceInBuffer()
//        XCTAssertTrue(matchState == .success)
//        switch matchState
//        {
//        case .success:
//            print("\nRemove sequence found!\n")
//        case .failure:
//            print("\nFailed to find remove sequence.\n")
//            XCTFail()
//        case .insufficientData:
//            print("\nBuffer was smaller than the remove sequence we were looking for.\n")
//            XCTFail()
//        }
//    }
//
//    func testOneSequence()
//    {
//        let sequence = SequenceModel(sequence: sequence1, length: 256)!
//        guard let toneBurst = Whalesong(addSequences: [sequence], removeSequences: [sequence])
//            else
//        {
//            XCTFail()
//            return
//        }
//
//        let transformState = toneBurst.generate()
//
//        switch transformState
//        {
//            case .failure:
//                XCTFail()
//                return
//
//            case .generating(let transformResult):
//                let restoreState = toneBurst.remove(newData: transformResult)
//                print("\nBuffer to transform: \n \(sequence1)\n")
//                print("\nTransform Result: \n \(transformResult)\n")
//
//                switch restoreState
//                {
//                case .completion:
//                    print("\nRestore Result: Complete\n")
//                default:
//                    print("\nRestore Result: \(restoreState)\n")
//                    XCTFail()
//                }
//
//            case .completion:
//                print("\nTransform Complete\n")
//        }
//    }
}
