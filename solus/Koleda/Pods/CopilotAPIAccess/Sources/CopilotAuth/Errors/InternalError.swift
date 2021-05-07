//
//  InternalError.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 23/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public class InternalError: Error {
    var message: String
    
    public init(message: String) {
        self.message = message
    }
}

extension InternalError: LocalizedError {
    
    public var errorDescription: String? {
        return message
    }
}
