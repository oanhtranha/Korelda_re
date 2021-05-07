//
//  RegisterError.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 23/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public enum SignupError: CopilotError {
    static func generalError(message: String) -> SignupError {
        return .generalError(debugMessage: message)
    }
    
    case userAlreadyExists(debugMessage: String)
    case passwordPolicyViolation(debugMessage: String)
    case invalidApplicationId(debugMessage: String)
    case invalidEmail(debugMessage: String)
    case invalidParameters(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}


public class SignupErrorResolver: ErrorResolver{
        public typealias T = SignupError

        public func fromRequiresReloginError(debugMessage: String) -> SignupError {
            return .generalError(debugMessage: "Unexpected requires login message")
        }

        public func fromInvalidParametersError(debugMessage: String) -> SignupError {
            return .invalidParameters(debugMessage: debugMessage)
        }

        public func fromGeneralError(debugMessage: String) -> SignupError {
            return .generalError(debugMessage: debugMessage)
        }

        public func fromConnectivityError(debugMessage: String) -> SignupError {
            return .connectivityError(debugMessage:debugMessage)
        }

        public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> SignupError? {
            if isInvalidApplicationId(statusCode, reason){
                return .invalidApplicationId(debugMessage: message)
            }
            if isUserAlreadyExists(statusCode, reason){
                return .userAlreadyExists(debugMessage: message)
            }
            if isPasswordPolicyViolation(statusCode, reason){
                return .passwordPolicyViolation(debugMessage:message)
            }
            if isInvalidEmail(statusCode, reason){
                return .invalidEmail(debugMessage: message)
            }
            return nil
        }
}





extension SignupError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Signup"
    }
    public var errorDescription: String? {
        switch self {
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        case .invalidApplicationId(let debugMessage):
            return toString("Invalid application Id (\(debugMessage)")
        case .invalidParameters(let debugMessage):
            return invalidParametersMessage(debugMessage: debugMessage)
        case .userAlreadyExists(let debugMessage):
            return toString("User already exists (\(debugMessage))")
        case .passwordPolicyViolation(let message):
            return toString("Password policy validation failed: \(message)")
        case .invalidEmail(let debugMessage):
            return toString("The email provided doesnt have a valid structure: \(debugMessage)")
        }
    }
}
