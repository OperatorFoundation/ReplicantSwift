import XCTest
import Foundation

import Datable
import Monolith
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
    
    func testMonotoneFixedItems()
    {
        var parts: [MonolithPart] = []
        let part1: MonolithPart = .bytes(BytesPart(items: [
            .fixed(FixedByteType(byte: 0x0A)),
            .fixed(FixedByteType(byte: 0x11))
        ]))
        parts.append(part1)
        
        let part2: MonolithPart = .bytes(BytesPart(items: [
            .fixed(FixedByteType(byte: 0xB0)),
            .fixed(FixedByteType(byte: 0xB1))
        ]))
        parts.append(part2)
        
        let description = Description(parts: parts)
        let instance = Instance(description: description, args: Args())
        
        let monotoneConfig = MonotoneConfig(addSequences: instance, removeSequences: description, speakFirst: true)
        _ = monotoneConfig.construct()
    }
    
    func testMonotoneEnumeratedItems()
    {
        let set: [uint8] = [0x11, 0x12, 0x13, 0x14]
        var parts: [MonolithPart] = []
        let part1: MonolithPart = .bytes(BytesPart(items: [
            .enumerated(EnumeratedByteType(options: set)),
            .enumerated(EnumeratedByteType(options: set))
        ]))
        parts.append(part1)
        
        let part2: MonolithPart = .bytes(BytesPart(items: [
            .enumerated(EnumeratedByteType(options: set)),
            .enumerated(EnumeratedByteType(options: set))
        ]))
        parts.append(part2)
        
        let desc = Description(parts: parts)
        let args = Args(byteValues: [0x11, 0x12, 0x14, 0x13])
        let instance = Instance(description: desc, args: args)
        let monotoneConfig = MonotoneConfig(addSequences: instance, removeSequences: desc, speakFirst: true)
        _ = monotoneConfig.construct()
    }
    
    func testMonotoneRandomEnumeratedItems()
    {
        let set: [uint8] = [0x11, 0x12, 0x13, 0x14]
        
        var parts: [MonolithPart] = []
        let part1: MonolithPart = .bytes(BytesPart(items: [
            .randomEnumerated(RandomEnumeratedByteType(randomOptions: set)),
            .randomEnumerated(RandomEnumeratedByteType(randomOptions: set))
        ]))
        parts.append(part1)
        
        let part2: MonolithPart = .bytes(BytesPart(items: [
            .randomEnumerated(RandomEnumeratedByteType(randomOptions: set)),
            .randomEnumerated(RandomEnumeratedByteType(randomOptions: set))
        ]))
        parts.append(part2)
        
        let desc = Description(parts: parts)
        let args = Args(byteValues: [0x11, 0x12, 0x14, 0x13])
        let instance = Instance(description: desc, args: args)
        let monotoneConfig = MonotoneConfig(addSequences: instance, removeSequences: desc, speakFirst: true)
        _ = monotoneConfig.construct()
    }
    
    func testMonotoneRandomItems()
    {
        var parts: [MonolithPart] = []
        let part1: MonolithPart = .bytes(BytesPart(items: [
            .random(RandomByteType()),
            .random(RandomByteType())
        ]))
        parts.append(part1)
        
        let part2: MonolithPart = .bytes(BytesPart(items: [
            .random(RandomByteType()),
            .random(RandomByteType())
        ]))
        parts.append(part2)
        
        let desc = Description(parts: parts)
        let args = Args(byteValues: [0x11, 0x12, 0x14, 0x13])
        let instance = Instance(description: desc, args: args)
        let monotoneConfig = MonotoneConfig(addSequences: instance, removeSequences: desc, speakFirst: true)
        _ = monotoneConfig.construct()
    }
    
    func createExampleWhalesongClientConfig() -> ToneBurstClientConfig?
    {
        // ToneBurst Config
        let sequence = SequenceModel(sequence: sequence1, length: 256)!
        let addSequences = [sequence]
        let removeSequences = [sequence]
        
        guard let whalesongClient = WhalesongClient(addSequences: addSequences, removeSequences: removeSequences)
        else
        {
            return nil
        }
        
        let toneBurstClientConfig = ToneBurstClientConfig.whalesong(client: whalesongClient)
        return toneBurstClientConfig
    }
    
    func testCreateEmptyReplicantClientConfigs()
    {
        let configDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true).appendingPathComponent("Configs", isDirectory: true)
        
        do
        {
            try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
        }
        catch
        {
            print("Failed to create the config directory: \(error)")
            XCTFail()
        }
        
        // Config with no ToneBurst or Polish
        let emptyTemplate = ReplicantConfigTemplate(polishClientConfig: nil, toneBurstConfig: nil)
        let configPath = configDirectory.appendingPathComponent("emptyReplicantConfig.json", isDirectory: false).path
        
        if FileManager.default.fileExists(atPath: configPath)
        {
            do
            {
                try FileManager.default.removeItem(atPath: configPath)
            }
            catch
            {
                XCTFail()
            }
        }
        
        let savedClientConfig = emptyTemplate.createClientConfig(atPath: configPath, serverIP: "127.0.0.1", port: 2277)
        XCTAssert(savedClientConfig)
    }
    
    func testCreateToneBurstOnlyReplicantClientConfig()
    {
        let configDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true).appendingPathComponent("Configs", isDirectory: true)
        
        do
        {
            try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
        }
        catch
        {
            print("Failed to create the config directory: \(error)")
            XCTFail()
        }
        
        // Config with ToneBurst only
        guard let toneBurstClientConfig = createExampleWhalesongClientConfig() else
        {
            XCTFail()
            return
        }
        
        let toneBurstOnlyReplicantTemplate = ReplicantConfigTemplate(polishClientConfig: nil, toneBurstConfig: toneBurstClientConfig)
        let configPath = configDirectory.appendingPathComponent("toneburstOnlyReplicantConfig.json", isDirectory: false).path
        
        if FileManager.default.fileExists(atPath: configPath)
        {
            do
            {
                try FileManager.default.removeItem(atPath: configPath)
            }
            catch
            {
                XCTFail()
            }
        }
        
        let savedClientConfig = toneBurstOnlyReplicantTemplate.createClientConfig(atPath: configPath, serverIP: "127.0.0.1", port: 2277)
        XCTAssert(savedClientConfig)
    }
    
    func testCreatePolishOnlyClientConfig()
    {
        let configDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true).appendingPathComponent("Configs", isDirectory: true)
        
        do
        {
            try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
        }
        catch
        {
            print("Failed to create the config directory: \(error)")
            XCTFail()
        }
        
        // Encode key as data
         guard let keyData = "NotARealKey".data(using: .utf8) else
         {
             print("Failed to load the provided key String as Data.")
             XCTFail()
             return
         }
        
        let polishClientConfig: PolishClientConfig = PolishClientConfig.silver(serverPublicKeyData: keyData, chunkSize: 1000, chunkTimeout: 1000)
        let polishOnlyReplicantTemplate = ReplicantConfigTemplate(polishClientConfig: polishClientConfig, toneBurstConfig: nil)
        let configPath = configDirectory.appendingPathComponent("polishOnlyReplicantConfig.json", isDirectory: false).path
        
        if FileManager.default.fileExists(atPath: configPath)
        {
            do
            {
                try FileManager.default.removeItem(atPath: configPath)
            }
            catch
            {
                XCTFail()
            }
        }
        
        let savedClientConfig = polishOnlyReplicantTemplate.createClientConfig(atPath: configPath, serverIP: "127.0.0.1", port: 2277)
        XCTAssert(savedClientConfig)
    }
    
    func testCreateSilverWhalesongClientConfig()
    {
        let configDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true).appendingPathComponent("Configs", isDirectory: true)
        
        do
        {
            try FileManager.default.createDirectory(at: configDirectory, withIntermediateDirectories: true)
        }
        catch
        {
            print("Failed to create the config directory: \(error)")
            XCTFail()
        }
        
        // Encode key as data
         guard let keyData = "NotARealKey".data(using: .utf8) else
         {
             print("Failed to load the provided key String as Data.")
             XCTFail()
             return
         }
        
        let polishClientConfig: PolishClientConfig = PolishClientConfig.silver(serverPublicKeyData: keyData, chunkSize: 1000, chunkTimeout: 1000)

        guard let toneBurstClientConfig = createExampleWhalesongClientConfig() else
        {
            XCTFail()
            return
        }
        
        let silverWhalesongClientConfigTemplate = ReplicantConfigTemplate(polishClientConfig: polishClientConfig, toneBurstConfig: toneBurstClientConfig)
        let clientConfigPath = configDirectory.appendingPathComponent("silverWhalesongReplicantClient.json", isDirectory: false).path
        
        if FileManager.default.fileExists(atPath: clientConfigPath)
        {
            do
            {
                try FileManager.default.removeItem(atPath: clientConfigPath)
            }
            catch
            {
                XCTFail()
            }
        }
        
        let savedClientConfig = silverWhalesongClientConfigTemplate.createClientConfig(atPath:  clientConfigPath, serverIP: "127.0.0.1", port: 2277)
        XCTAssert(savedClientConfig)
    }
    
    
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
