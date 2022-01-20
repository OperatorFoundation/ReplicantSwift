//
//  CodableExtensions.swift
//  
//
//  Created by Mafalda on 1/19/22.
//

import Crypto
import Foundation
import Logging

extension Logger: Codable
{
    enum CodingKeys: CodingKey
    {
        case label
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let labelValue = try container.decode(String.self, forKey: .label)
        self = Logger(label: labelValue)
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.label, forKey: .label)
    }
}
