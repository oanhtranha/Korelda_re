//
//  RefreshTokenError.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 23/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
public typealias LoginSilentlyError = RefreshTokenError

public enum RefreshTokenError: CopilotError {
    static func generalError(message: String) -> RefreshTokenError {
        return .generalError(debugMessage: message)
    }
    
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class RefreshTokenErrorResolver : ErrorResolver{
    public typealias T = RefreshTokenError
    
    public func fromRequiresReloginError(debugMessage: String) -> RefreshTokenError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> RefreshTokenError {
        return .generalError(debugMessage: "Unexpected invalid parameters \(debugMessage)")
    }
    
    public func fromGeneralError(debugMessage: String) -> RefreshTokenError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> RefreshTokenError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> RefreshTokenError? {
        if isMarkedForDeletion(statusCode, reason){
            return .requiresRelogin(debugMessage: "Marked for deleation")
        }
        return nil
    }
}





extension RefreshTokenError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Refresh Token"
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
