//
//  ConsentError.swift
//  AOTAuth
//
//  Created by Tom Milberg on 13/05/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public enum UpdateUserConsentError : CopilotError {
    static func generalError(message: String) -> UpdateUserConsentError {
        return .generalError(debugMessage: message)
    }
    
    case invalidParameters(debugMessage: String)
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class UpdateUserConsentErrorResolver : ErrorResolver{
    public typealias T = UpdateUserConsentError
    
    public func fromRequiresReloginError(debugMessage: String) -> UpdateUserConsentError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> UpdateUserConsentError {
        return .invalidParameters(debugMessage: debugMessage)
    }
    
    public func fromGeneralError(debugMessage: String) -> UpdateUserConsentError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> UpdateUserConsentError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> UpdateUserConsentError? {
        if isMarkedForDeletion(statusCode, reason){
            return .requiresRelogin(debugMessage: "Marked for deletion")
        }
        return nil
    }
}





extension UpdateUserConsentError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Update User Consent"
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidParameters(let debugMessage):
            return invalidParametersMessage(debugMessage: debugMessage)
        case .requiresRelogin(let debugMessage):
            return requiresReloginMessage(debugMessage: debugMessage)
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        }
    }
}
