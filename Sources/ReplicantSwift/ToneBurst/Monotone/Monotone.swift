//
//  Monotone.swift
//  
//
//  Created by Mafalda on 2/8/22.
//

import Foundation

import Monolith
import Transmission

public class Monotone: ToneBurst
{
    let config: MonotoneConfig
    var buffer: Buffer
    var context: Context
    
    public init(config: MonotoneConfig)
    {
        self.config = config
        self.buffer = Buffer()
        self.context = Context()
    }
    
    public func perform(connection: Connection, completion: @escaping (Error?) -> Void)
    {
        var addMessages: [Message] = config.addSequences.messages()
        var removeParts: [MonolithPart] = config.removeSequences.parts
        
        if config.speakFirst
        {
            guard !addMessages.isEmpty else
            {
                completion(MonotoneError.speakFirstNoAddSequence)
                return
            }
            
            //Pop the first sequence in the list of add sequences
            var firstMessage = addMessages.removeFirst()
            let addBytes = firstMessage.bytes()
            
            // Send the first message
            writeAll(connection: connection, addBytes: Data(addBytes))
            {
                (maybeWriteError) in
                
                if let writeError = maybeWriteError
                {
                    completion(writeError)
                    return
                }
            }
        }
        
        while (!removeParts.isEmpty && !addMessages.isEmpty)
        {
            if !removeParts.isEmpty
            {
                let firstPart = removeParts.removeFirst()
                
                readAll(connection: connection, part: firstPart)
                {
                    (maybeReadError) in
                    
                    if let readError = maybeReadError
                    {
                        completion(readError)
                        return
                    }
                }
            }
            
            if !addMessages.isEmpty
            {
                var nextMessage = addMessages.removeFirst()
                let nextAddBytes = nextMessage.bytes()
                
                // Send the first message
                writeAll(connection: connection, addBytes: Data(nextAddBytes))
                {
                    (maybeWriteError) in
                    
                    if let writeError = maybeWriteError
                    {
                        completion(writeError)
                        return
                    }
                }
            }
        }
    }
    
    func writeAll(connection: Transmission.Connection, addBytes: Data, completion: @escaping (Error?) -> Void)
    {
        let writeSucceeded = connection.write(data: addBytes)
        
        if writeSucceeded
        {
            completion(nil)
            return
        }
        else
        {
            completion(MonotoneError.writeError)
            return
        }
    }
    
    
    func readAll(connection: Transmission.Connection, part: MonolithPart, completion: @escaping (Error?) -> Void)
    {
        switch part
        {
            case .bytes(let bytesPart):
                guard let receivedData = connection.read(size: bytesPart.count()) else
                {
                    completion(MonotoneError.readError)
                    return
                }
                
                buffer.push(bytes: receivedData.bytes)
        }
        
        let validated = part.validate(buffer: buffer, context: &context)
        
        switch validated
        {
            case .valid:
                completion(nil)
            case .invalid:
                completion(MonotoneError.receiveDataInvalid)
            case .incomplete:
                completion(MonotoneError.receiveDataIncomplete)
        }
    }
    
}
