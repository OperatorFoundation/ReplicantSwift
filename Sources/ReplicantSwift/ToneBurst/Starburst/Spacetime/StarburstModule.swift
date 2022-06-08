//
//  StarburstModule.swift
//  
//
//  Created by Dr. Brandon Wiley on 6/7/22.
//

import Foundation

import Chord
import Ghostwriter
import Simulation
import Spacetime
import TransmissionTypes
import Universe

public class StarburstModule: Module
{
    static public let name = "Starburst"

    let connection: TransmissionTypes.Connection
    let lock: DispatchSemaphore = DispatchSemaphore(value: 0)

    public init(_ connection: TransmissionTypes.Connection)
    {
        self.connection = connection
    }

    public func name() -> String
    {
        return StarburstModule.name
    }

    public func handleEffect(_ effect: Effect, _ channel: BlockingQueue<Event>) -> Event?
    {
        switch effect
        {
            case let request as SpeakRequest:
                return self.speak(request)

            case let request as StarburstListenRequest:
                return self.listen(request)

            case let request as WaitRequest:
                return self.wait(request)

            default:
                return Failure(effect.id)
        }
    }

    public func handleExternalEvent(_ event: Event)
    {
        return
    }

    func speak(_ effect: SpeakRequest) -> Event?
    {
        switch effect.speak
        {
            case .bytes(let data):
                guard connection.write(data: data) else
                {
                    return Failure(effect.id)
                }

            case .text(let string):
                guard connection.write(string: string) else
                {
                    return Failure(effect.id)
                }

            case .template(let template, let details):
                do
                {
                    let string = try Ghostwriter.generate(template, details)
                    guard connection.write(string: string) else
                    {
                        return Failure(effect.id)
                    }
                }
                catch
                {
                    print(error)
                    return Failure(effect.id)
                }
        }

        return SpeakResponse(effect.id)
    }

    func listen(_ effect: StarburstListenRequest) -> Event?
    {
        switch effect.listen
        {
            case .bytes(let size):
                guard let data = self.connection.read(size: size) else
                {
                    return Failure(effect.id)
                }

                let result = StarburstListenResult.data(data)

                return StarburstListenResponse(effect.id, result)

            case .text(let size):
                guard let data = self.connection.read(size: size) else
                {
                    return Failure(effect.id)
                }

                guard let string = String(data: data, encoding: .utf8) else
                {
                    return Failure(effect.id)
                }

                let result = StarburstListenResult.text(string)
                return StarburstListenResponse(effect.id, result)

            case .parse(let template):
                let resultQueue = BlockingQueue<StarburstListenResult?>()
                let queue = DispatchQueue(label: "StarburstModule.listen.parse")

                queue.async
                {
                    var buffer = Data()
                    while true
                    {
                        guard let byte = self.connection.read(size: 1) else
                        {
                            resultQueue.enqueue(element: nil)
                            self.lock.signal()
                            return
                        }

                        buffer.append(byte)

                        guard let string = String(data: buffer, encoding: .utf8) else
                        {
                            // This could fail because we're in the middle of a UTF8 rune.
                            continue
                        }

                        do
                        {
                            let details = try Ghostwriter.parse(template.template, template.patterns, string)
                            let result = StarburstListenResult.parse(details)
                            resultQueue.enqueue(element: result)
                            self.lock.signal()
                            return
                        }
                        catch
                        {
                            print(error)
                            resultQueue.enqueue(element: nil)
                            self.lock.signal()
                            return
                        }
                    }
                }

                let waitResult = self.lock.wait(timeout: .now() + template.maxTimeoutSeconds)
                switch waitResult
                {
                    case .success:
                        guard let result = resultQueue.dequeue() else
                        {
                            return Failure(effect.id)
                        }

                        return StarburstListenResponse(effect.id, result)

                    case .timedOut:
                        return Failure(effect.id)
                }

            case .match(let template):
                let resultQueue = BlockingQueue<StarburstListenResult?>()
                let queue = DispatchQueue(label: "StarburstModule.listen.parse")

                queue.async
                {
                    var buffer = Data()
                    while true
                    {
                        guard let byte = self.connection.read(size: 1) else
                        {
                            resultQueue.enqueue(element: nil)
                            self.lock.signal()
                            return
                        }

                        buffer.append(byte)

                        guard buffer.count <= template.maxSize else
                        {
                            resultQueue.enqueue(element: nil)
                            self.lock.signal()
                            return
                        }

                        guard let string = String(data: buffer, encoding: .utf8) else
                        {
                            // This could give a false negative because we're in the middle of a UTF8 sequence.
                            continue
                        }

                        do
                        {
                            let details = try Ghostwriter.parse(template.template, template.patterns, string)
                            guard details.count == template.answers.count else
                            {
                                continue
                            }

                            var matched = true
                            for (detail, answer) in zip(details, template.answers)
                            {
                                guard detail == answer else
                                {
                                    // This could fail because we don't have all the bytes yet.
                                    matched = false
                                    break
                                }
                            }

                            guard matched else
                            {
                                continue
                            }

                            let result = StarburstListenResult.match
                            resultQueue.enqueue(element: result)
                            self.lock.signal()
                            return
                        }
                        catch
                        {
                            print(error)
                            resultQueue.enqueue(element: nil)
                            self.lock.signal()
                            return
                        }
                    }
                }

                let waitResponse = self.lock.wait(timeout: .now() + template.maxTimeoutSeconds)
                switch waitResponse
                {
                    case .success:
                        guard let result = resultQueue.dequeue() else
                        {
                            return Failure(effect.id)
                        }

                        return StarburstListenResponse(effect.id, result)

                    case .timedOut:
                        return Failure(effect.id)
                }
            }
    }

    func wait(_ effect: WaitRequest) -> Event?
    {
        // FIXME
        return nil
    }
}
