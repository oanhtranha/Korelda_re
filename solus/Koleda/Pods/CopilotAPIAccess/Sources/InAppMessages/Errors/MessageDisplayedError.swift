//
//  MessageDisplayedError.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

public enum MessageDisplayedError: Error {
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class FetchMessageDisplayedErrorResolver: ErrorResolver {
    public typealias T = MessageDisplayedError
    
    public func fromRequiresReloginError(debugMessage: String) -> MessageDisplayedError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> MessageDisplayedError {
        return .generalError(debugMessage: "Unexpected invalid parameters \(debugMessage)")
    }
    
    public func fromGeneralError(debugMessage: String) -> MessageDisplayedError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> MessageDisplayedError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> MessageDisplayedError? {
        return nil
    }
}



extension MessageDisplayedError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Post Message Display"
    }
    
    public var errorDescription: String? {
        switch self {
        case .requiresRelogin(let debugMessage):
            return requiresReloginMessage(debugMessage: debugMessage)
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        }
    }
}
