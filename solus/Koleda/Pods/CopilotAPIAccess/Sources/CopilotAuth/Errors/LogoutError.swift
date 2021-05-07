//
//  LogoutError.swift
//  CopilotAuth
//
//  Created by Adaya on 05/12/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public enum LogoutError: CopilotError {
    static func generalError(message: String) -> LogoutError {
        return .internalError(InternalError(message: message))
    }
    
    case internalError(Error)
}
