//
//  RequireResetPasswordError.swift
//  CopilotAuth
//
//  Created by Adaya on 06/12/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public enum ResetPasswordError:  CopilotError {
    static func generalError(message: String) -> ResetPasswordError {
        return .generalError(debugMessage: message)
    }
    
    case invalidParameters(debugMessage: String)
    case emailIsNotVerified(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}



public class ResetPasswordErrorResolver: ErrorResolver{
    public typealias T = ResetPasswordError
    
    public func fromRequiresReloginError(debugMessage: String) -> ResetPasswordError {
        return .generalError(debugMessage: "Unexpected requires login message")
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> ResetPasswordError {
        return .invalidParameters(debugMessage: debugMessage)
    }
    
    public func fromGeneralError(debugMessage: String) -> ResetPasswordError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> ResetPasswordError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> ResetPasswordError? {
        if isEmailNotVerified(statusCode, reason){
            return .emailIsNotVerified(debugMessage: message)
        }
        return nil
    }
}


extension ResetPasswordError : CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Reset Password"
    }
    
    public var errorDescription: String? {
        switch self {
            
        case .invalidParameters(let debugMessage):
            return invalidParametersMessage(debugMessage: debugMessage)
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        case .emailIsNotVerified(let debugMessage):
            return toString("Cannot send a password reset email to a non verified email (\(debugMessage))")
        }
    }
}
