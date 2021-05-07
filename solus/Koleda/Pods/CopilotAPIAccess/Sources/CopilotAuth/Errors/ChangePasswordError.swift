//
//  ChangePasswordError.swift
//  CopilotAPIAccess
//
//  Created by Adaya on 07/03/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public enum ChangePasswordError: CopilotError {
    static func generalError(message: String) -> ChangePasswordError {
        return .generalError(debugMessage: message)
    }
    
    case invalidCredentials(debugMessage: String)
    case passwordPolicyViolation(debugMessage: String)
    case cannotChangePasswordToAnonymousUser(debugMessage: String)
    case requiresRelogin(debugMessage: String)
    case invalidParameters(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}



public class ChangePasswordErrorResolver: ErrorResolver{
    public typealias T = ChangePasswordError
    
    public func fromRequiresReloginError(debugMessage: String) -> ChangePasswordError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> ChangePasswordError {
        return .invalidParameters(debugMessage: debugMessage)
    }
    
    public func fromGeneralError(debugMessage: String) -> ChangePasswordError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> ChangePasswordError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> ChangePasswordError? {
        if isMarkedForDeletion(statusCode, reason){
            return .requiresRelogin(debugMessage: "Marked for deletion")
        }
        if isPasswordPolicyViolation(statusCode, reason){
            return .passwordPolicyViolation(debugMessage:message)
        }
        if isPasswordResetFailed(statusCode, reason){
            return .invalidCredentials(debugMessage:message)
        }
        if isInvalidPermissions(statusCode, reason){
            return .cannotChangePasswordToAnonymousUser(debugMessage: message)
        }
        return nil
    }
}


extension ChangePasswordError : CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Change Password"
    }
    
    public var errorDescription: String? {
        switch self {
        case .passwordPolicyViolation(let message):
            return toString("Password policy validation failed: \(message)")
        case .invalidCredentials(let debugMessage):
            return toString("Old password was invalid: \(debugMessage)")
        case .requiresRelogin(let debugMessage):
            return requiresReloginMessage(debugMessage: debugMessage)
        case .invalidParameters(let debugMessage):
            return invalidParametersMessage(debugMessage: debugMessage)
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        case .cannotChangePasswordToAnonymousUser(let debugMessage):
            return toString("An Anonymous user cannot change a password (\(debugMessage))")
        }
    }
}
