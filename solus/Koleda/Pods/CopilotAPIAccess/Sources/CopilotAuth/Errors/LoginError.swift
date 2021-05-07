//
//  LoginError.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 23/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public enum LoginError: CopilotError {
    static func generalError(message: String) -> LoginError {
        return .generalError(debugMessage: message)
    }
    
    case markedForDeletion(debugMessage: String)
    case unauthorized(debugMessage: String)
    case invalidParameters(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class LoginErrorResolver : ErrorResolver{
    public typealias T = LoginError
    
    public func fromRequiresReloginError(debugMessage: String) -> LoginError {
        return .unauthorized(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> LoginError {
        return .invalidParameters(debugMessage: debugMessage)
    }
    
    public func fromGeneralError(debugMessage: String) -> LoginError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> LoginError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> LoginError? {
        if isMarkedForDeletion(statusCode, reason){
            return .markedForDeletion(debugMessage: message)
        }
        return nil
    }
}





extension LoginError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Login"
    }
    
    public var errorDescription: String? {
        switch self {
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        case .markedForDeletion(let debugMessage):
            return toString("User is marked for deletion (\(debugMessage)")
        case .unauthorized(let debugMessage):
            return toString("Either email or password are incorrect (\(debugMessage)")
        case .invalidParameters(let debugMessage):
            return invalidParametersMessage(debugMessage: debugMessage)
        }
    }
}
