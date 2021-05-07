//
//  RegisterAnonymouslyError.swift
//  CopilotAPIAccess
//
//  Created by Richard Houta on 08/10/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

public enum SignupAnonymouslyError: CopilotError {
    static func generalError(message: String) -> SignupAnonymouslyError {
        return .generalError(debugMessage: message)
    }
    
    case invalidApplicationId(debugMessage: String)
    case invalidParameters(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}


public class SignupAnonymousErrorResolver: ErrorResolver{
    public typealias T = SignupAnonymouslyError
    
    public func fromRequiresReloginError(debugMessage: String) -> SignupAnonymouslyError {
        return .generalError(debugMessage: "Unexpected requires login message")
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> SignupAnonymouslyError {
        return .invalidParameters(debugMessage: debugMessage)
    }
    
    public func fromGeneralError(debugMessage: String) -> SignupAnonymouslyError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> SignupAnonymouslyError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> SignupAnonymouslyError? {
        if isInvalidApplicationId(statusCode, reason){
            return .invalidApplicationId(debugMessage: message)
        }
        return nil
    }
}


extension SignupAnonymouslyError : CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Signup Anonymous"
    }
    
    public var errorDescription: String? {
        switch self {
        
        case .invalidApplicationId(let debugMessage):
            return toString("Invalid application id (\(debugMessage)")
        case .invalidParameters(let debugMessage):
            return invalidParametersMessage(debugMessage: debugMessage)
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        }
    }
}
