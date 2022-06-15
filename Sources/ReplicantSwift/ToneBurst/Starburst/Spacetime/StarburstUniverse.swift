//
//  StarburstUniverse.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Ghostwriter
import Spacetime
import Universe

public class StarburstUniverse: Universe
{
    public func speak(_ uuid: UUID, _ string: String) throws
    {
        let parameters = Speak.text(string)
        try self.speak(uuid, parameters)
    }

    public func speak(_ uuid: UUID, _ data: Data) throws
    {
        let parameters = Speak.bytes(data)
        try self.speak(uuid, parameters)
    }

    public func speak(_ uuid: UUID, _ template: Template, _ details: [Detail]) throws
    {
        let parameters = Speak.template(template, details)
        try self.speak(uuid, parameters)
    }

    func speak(_ uuid: UUID, _ parameters: Speak) throws
    {
        let effect = SpeakRequest(universe: self, uuid: uuid, speak: parameters)
        let result: Event = self.processEffect(effect)
        switch result
        {
            case is SpeakResponse:
                return

            default:
                throw StarburstUniverseError.speakFailed
        }
    }

    public func listenForData(_ uuid: UUID, size: Int) throws -> Data
    {
        let parameters = Listen.bytes(size)
        let result = try self.listen(uuid, parameters)
        switch result
        {
            case .data(let value):
                return value

            default:
                throw StarburstUniverseError.wrongResultType
        }
    }

    public func listenForString(_ uuid: UUID, size: Int) throws -> String
    {
        let parameters = Listen.text(size)
        let result = try self.listen(uuid, parameters)
        switch result
        {
            case .text(let value):
                return value

            default:
                throw StarburstUniverseError.wrongResultType
        }
    }

    public func listenParse(_ uuid: UUID, template: ListenTemplate) throws -> [Detail]
    {
        let parameters = Listen.parse(template)
        let result = try self.listen(uuid, parameters)
        switch result
        {
            case .parse(let value):
                return value

            default:
                throw StarburstUniverseError.wrongResultType
        }
    }

    public func listenMatch(_ uuid: UUID, template: ListenTemplate) throws -> Bool
    {
        let parameters = Listen.match(template)
        let result = try self.listen(uuid, parameters)
        switch result
        {
            case .match:
                return true

            default:
                return false
        }
    }

    func listen(_ uuid: UUID, _ parameters: Listen) throws -> StarburstListenResult
    {
        let effect = StarburstListenRequest(self, uuid, parameters)
        let result: Event = self.processEffect(effect)
        switch result
        {
            case let response as StarburstListenResponse:
                return response.result

            default:
                throw StarburstUniverseError.listenFailed
        }
    }

    public func wait(_ interval: TimeInterval) throws
    {
        let effect = WaitRequest(interval)
        let result: Event = self.processEffect(effect)
        switch result
        {
            case is WaitResponse:
                return

            default:
                throw StarburstUniverseError.waitFailed
        }
    }
}

public enum StarburstUniverseError: Error
{
    case speakFailed
    case listenFailed
    case wrongResultType
    case waitFailed
}
