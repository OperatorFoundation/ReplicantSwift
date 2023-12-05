import XCTest
import Foundation
import Logging

import Datable
import KeychainTypes
import Monolith
import ShadowSwift
import SwiftQueue

@testable import ReplicantSwift

final class ReplicantSwiftTests: XCTestCase
{
    let logger = Logger(label: "ReplicantTest")
    
    func testStarburstAndDarkstarServer() throws {
        let serverSendData = "success".data
        let clientSendData = "pass".data
        guard let replicantServerConfig = ReplicantServerConfig(withConfigAtPath: "~/ReplicantServerConfig.json") else {
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
        
        let starburstServer = Starburst(.SMTPServer)
        let starburstClient = Starburst(.SMTPClient)
        
        let replicantServerConfig = ReplicantServerConfig(serverAddress: "127.0.0.1:1234", polish: nil, toneBurst: starburstServer, transport: "Replicant")
        
        guard let replicantClientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: nil, toneBurst: starburstClient, transport: "Replicant") else
        {
            XCTFail()
            return
        }
        
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
        
        guard let replicantClientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: polishClient, toneBurst: nil, transport: "Replicant") else
        {
            XCTFail()
            return
        }
        
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
        let toneBurstServer = Starburst(.SMTPServer)
        let toneBurstClient = Starburst(.SMTPClient)
        let privateKey = try PrivateKey(type: .P256KeyAgreement)
        let polishClient = PolishClientConfig(serverAddress: "127.0.0.1:1234", serverPublicKey: privateKey.publicKey)
        let polishServer = PolishServerConfig(serverAddress: "127.0.0.1:1234", serverPrivateKey: privateKey)
        
        let replicantServerConfig = ReplicantServerConfig(serverAddress: "127.0.0.1:1234", polish: polishServer, toneBurst: toneBurstServer, transport: "Replicant")
        
        guard let replicantClientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: polishClient, toneBurst: toneBurstClient, transport: "Replicant") else
        {
            XCTFail()
            return
        }
        
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
        guard let privateKey = try? PrivateKey(type: .P256KeyAgreement) else {
            XCTFail()
            return
        }
        
        let publicKey = privateKey.publicKey
        let polishClientConfig = PolishClientConfig(serverAddress: "127.0.0.1:1234", serverPublicKey: publicKey)
        let polishServerConfig = PolishServerConfig(serverAddress: "127.0.0.1:1234", serverPrivateKey: privateKey)
        let toneburstClient = Starburst(.SMTPClient)
        let toneburstServer = Starburst(.SMTPServer)
        guard let clientConfig = ReplicantClientConfig(serverAddress: "127.0.0.1:1234", polish: polishClientConfig, toneBurst: toneburstClient, transport: "Replicant") else
        {
            XCTFail("Failed to create a ReplicantClientConfig")
            return
        }
        let serverConfig = ReplicantServerConfig(serverAddress: "127.0.0.1:1234", polish: polishServerConfig, toneBurst: toneburstServer, transport: "Replicant")
        
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

}
