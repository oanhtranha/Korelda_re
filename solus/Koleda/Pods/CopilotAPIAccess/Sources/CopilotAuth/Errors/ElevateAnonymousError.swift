//
//  ElevateAnonymousError.swift
//  CopilotAPIAccess
//
//  Created by Richard Houta on 08/10/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

public enum ElevateAnonymousUserError: CopilotError {
    static func generalError(message: String) -> ElevateAnonymousUserError {
        return .generalError(debugMessage: message)
    }
    
    case requiresRelogin(debugMessage: String)
    case cannotElevateANonAnonymousUser(debugMessage: String)
    case userAlreadyExists(debugMessage: String)
    case passwordPolicyViolation(debugMessage: String)
    case invalidEmail(debugMessage: String)
    case invalidParameters(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}


public class ElevateAnonymousErrorResolver: ErrorResolver{
    public typealias T = ElevateAnonymousUserError
    
    public func fromRequiresReloginError(debugMessage: String) -> ElevateAnonymousUserError {
        return .requiresRelogin(debugMessage:debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> ElevateAnonymousUserError {
        return .invalidParameters(debugMessage: debugMessage)
    }
    
    public func fromGeneralError(debugMessage: String) -> ElevateAnonymousUserError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> ElevateAnonymousUserError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> ElevateAnonymousUserError? {
        if isMarkedForDeletion(statusCode, reason){
            return .requiresRelogin(debugMessage: message)
        }
        if isUserAlreadyExists(statusCode, reason){
            return .userAlreadyExists(debugMessage: message)
        }
        if isPasswordPolicyViolation(statusCode, reason){
            return .passwordPolicyViolation(debugMessage: message)
        }
        if isInvalidPermissions(statusCode, reason){
            return .cannotElevateANonAnonymousUser(debugMessage: message)
        }
        if isInvalidEmail(statusCode, reason){
            return .invalidEmail(debugMessage: message)
        }
        return nil
    }
}





extension ElevateAnonymousUserError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Elevate Anonymous"
    }
    public var errorDescription: String? {
        switch self {
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        case .invalidParameters(let debugMessage):
            return invalidParametersMessage(debugMessage: debugMessage)
        case .userAlreadyExists(let debugMessage):
            return toString("User already exists (\(debugMessage)")
        case .passwordPolicyViolation(let message):
            return toString("Password policy validation failed: \(message)")
        case .requiresRelogin(let debugMessage):
            return toString("Anonymous session expired, the user must be redirected to login/ registration (\(debugMessage)")
        case .cannotElevateANonAnonymousUser(let debugMessage):
            return toString("The current user is not anonymous and cannot be elevated (\(debugMessage)")
        case .invalidEmail(let debugMessage):
            return toString("The email provided doesn't have a valid structure \(debugMessage)")
        }
    }
}
