import XCTest
import Foundation

#if os(macOS) || os(iOS)
import os.log
#else
import Logging
#endif

import Datable
import KeychainTypes
import Monolith
import ShadowSwift
import SwiftQueue

@testable import ReplicantSwift

final class ReplicantSwiftTests: XCTestCase
{
    #if os(macOS) || os(iOS)
    let logger = Logger(subsystem: "org.operatorfoundation.replicant", category: "Test")
    #else
    let logger = Logger(label: "ReplicantTest")
    #endif
    
    func testStarburstAndDarkstarServer() throws {
        let serverSendData = "success".data
        let clientSendData = "pass".data
        guard let replicantServerConfig = ReplicantServerConfig(withConfigAtPath: "/Users/bluesaxorcist/Desktop/ReplicantServerConfig.json") else {
            XCTFail()
            return
        }
        let replicant = Replicant(logger: self.logger)
        
        let replicantListener = try replicant.listen(address: "127.0.0.1", port: 1234, config: replicantServerConfig)
        
        let replicantConnection = try replicantListener.accept()
        
        guard let serverReadData = replicantConnection.read(size: clientSendData.count) else {
            XCTFail()
            return
        }
        
        guard replicantConnection.write(data: serverSendData) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(serverReadData.string, clientSendData.string)
        
    }
    
    func testStarburst() throws {
        let serverSendData = "success".data
        let clientSendData = "pass".data
        
        let starburstServer = StarburstConfig(mode: StarburstMode.SMTPServer)
        let starburstClient = StarburstConfig(mode: StarburstMode.SMTPClient)
        
        let toneburstServerConfig = ToneBurstServerConfig.starburst(config: starburstServer)
        let toneBurstClientConfig = ToneBurstClientConfig.starburst(config: starburstClient)
        
        let replicantServerConfig = ReplicantServerConfig(serverAddress: "127.0.0.1:1234", polish: nil, toneBurst: toneburstServerConfig, transport: "Replicant")
        
        let replicantClientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: nil, toneBurst: toneBurstClientConfig, transport: "Replicant")
        
        let replicant = Replicant(logger: self.logger)
        
        let replicantListener = try replicant.listen(address: "127.0.0.1", port: 1234, config: replicantServerConfig)
        Task {
            let replicantConnection = try replicantListener.accept()
            
            guard let serverReadData = replicantConnection.read(size: clientSendData.count) else {
                XCTFail()
                return
            }
            
            guard replicantConnection.write(data: serverSendData) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(serverReadData.string, clientSendData.string)
        }
        
        let replicantClient = try replicant.connect(host: "127.0.0.1", port: 1234, config: replicantClientConfig)
        
        guard replicantClient.write(data: clientSendData) else {
            XCTFail()
            return
        }
        
        guard let clientReadData = replicantClient.read(size: serverSendData.count) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(clientReadData.string, serverSendData.string)
    }
    
    func testDarkstar() throws {
        let serverSendData = "success".data
        let clientSendData = "pass".data
        let privateKey = try PrivateKey(type: .P256KeyAgreement)
        let polishClient = PolishClientConfig(serverAddress: "127.0.0.1:1234", serverPublicKey: privateKey.publicKey)
        let polishServer = PolishServerConfig(serverAddress: "127.0.0.1:1234", serverPrivateKey: privateKey)
        
        let replicantServerConfig = ReplicantServerConfig(serverAddress: "127.0.0.1:1234", polish: polishServer, toneBurst: nil, transport: "Replicant")
        
        let replicantClientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: polishClient, toneBurst: nil, transport: "Replicant")
        
        let replicant = Replicant(logger: self.logger)
        
        let replicantListener = try replicant.listen(address: "127.0.0.1", port: 1234, config: replicantServerConfig)
        Task {
            let replicantConnection = try replicantListener.accept()
            
            guard let serverReadData = replicantConnection.read(size: clientSendData.count) else {
                XCTFail()
                return
            }
            
            guard replicantConnection.write(data: serverSendData) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(serverReadData.string, clientSendData.string)
        }
        
        let replicantClient = try replicant.connect(host: "127.0.0.1", port: 1234, config: replicantClientConfig)
        
        guard replicantClient.write(data: clientSendData) else {
            XCTFail()
            return
        }
        
        guard let clientReadData = replicantClient.read(size: serverSendData.count) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(clientReadData.string, serverSendData.string)
    }
    
    func testStarburstAndDarkstar() throws {
        let serverSendData = "success".data
        let clientSendData = "pass".data
        
        let starburstServer = StarburstConfig(mode: StarburstMode.SMTPServer)
        let starburstClient = StarburstConfig(mode: StarburstMode.SMTPClient)
        
        let toneburstServerConfig = ToneBurstServerConfig.starburst(config: starburstServer)
        let toneBurstClientConfig = ToneBurstClientConfig.starburst(config: starburstClient)
        let privateKey = try PrivateKey(type: .P256KeyAgreement)
        let polishClient = PolishClientConfig(serverAddress: "127.0.0.1:1234", serverPublicKey: privateKey.publicKey)
        let polishServer = PolishServerConfig(serverAddress: "127.0.0.1:1234", serverPrivateKey: privateKey)
        
        let replicantServerConfig = ReplicantServerConfig(serverAddress: "127.0.0.1:1234", polish: polishServer, toneBurst: toneburstServerConfig, transport: "Replicant")
        
        let replicantClientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: polishClient, toneBurst: toneBurstClientConfig, transport: "Replicant")
        
        let replicant = Replicant(logger: self.logger)
        
        let replicantListener = try replicant.listen(address: "127.0.0.1", port: 1234, config: replicantServerConfig)
        Task {
            let replicantConnection = try replicantListener.accept()
            
            guard let serverReadData = replicantConnection.read(size: clientSendData.count) else {
                XCTFail()
                return
            }
            
            guard replicantConnection.write(data: serverSendData) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(serverReadData.string, clientSendData.string)
        }
        
        let replicantClient = try replicant.connect(host: "127.0.0.1", port: 1234, config: replicantClientConfig)
        
        guard replicantClient.write(data: clientSendData) else {
            XCTFail()
            return
        }
        
        guard let clientReadData = replicantClient.read(size: serverSendData.count) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(clientReadData.string, serverSendData.string)
    }
    
    func testCreateConfigs() throws {
        let starburstServer = StarburstConfig(mode: StarburstMode.SMTPServer)
        let starburstClient = StarburstConfig(mode: StarburstMode.SMTPClient)
        guard let privateKey = try? PrivateKey(type: .P256KeyAgreement) else {
            XCTFail()
            return
        }
        
        let publicKey = privateKey.publicKey
        let shadowClientConfig = ShadowConfig.ShadowClientConfig(serverAddress: "127.0.0.1:1234", serverPublicKey: publicKey, mode: .DARKSTAR)
        let shadowServerConfig = ShadowConfig.ShadowServerConfig(serverAddress: "127.0.0.1:1234", serverPrivateKey: privateKey, mode: .DARKSTAR)
        let polishClientConfig = PolishClientConfig(serverAddress: "127.0.0.1:1234", serverPublicKey: publicKey)
        let polishServerConfig = PolishServerConfig(serverAddress: "127.0.0.1:1234", serverPrivateKey: privateKey)
        let toneburstClientConfig = ToneBurstClientConfig.starburst(config: starburstClient)
        let toneburstServerConfig = ToneBurstServerConfig.starburst(config: starburstServer)
        let clientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: polishClientConfig, toneBurst: toneburstClientConfig, transport: "Replicant")
        let serverConfig = ReplicantServerConfig(serverAddress: "127.0.0.1:1234", polish: polishServerConfig, toneBurst: toneburstServerConfig, transport: "Replicant")
        
        guard let clientJson = clientConfig.createJSON() else {
            XCTFail()
            return
        }
        
        guard let serverJson = serverConfig.createJSON() else {
            XCTFail()
            return
        }
        
        let fileManager = FileManager.default
        let clientConfigDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)
        let clientConfigPath = clientConfigDirectory.appendingPathComponent("ReplicantClientConfig.json", isDirectory: false).path
        let serverConfigDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)
        let serverConfigPath = serverConfigDirectory.appendingPathComponent("ReplicantServerConfig.json", isDirectory: false).path
        let clientConfigCreated = fileManager.createFile(atPath: clientConfigPath, contents: clientJson)
        let serverConfigCreated = fileManager.createFile(atPath: serverConfigPath, contents: serverJson)
        XCTAssertTrue(clientConfigCreated)
        XCTAssertTrue(serverConfigCreated)
    }
    
    // MARK: ToneBurst
    let sequence1 = Data(string: "OH HELLO")
    let sequence2 = Data(string: "You say hello, and I say goodbye.")
    let sequence3 = Data(string: "I don't know why you say 'Goodbye', I say 'Hello'.")

    func testCreateEmptyReplicantClientConfigs()
    {
        let configDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Desktop/Configs", isDirectory: true)
        
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
        
        let savedClientConfig = emptyTemplate.createClientConfig(atPath: configPath, serverAddress: "127.0.0.1:2277")
        XCTAssert(savedClientConfig)
    }
}
