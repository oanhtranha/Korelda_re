//
//  SendVerificationEmailError.swift
//  CopilotAPIAccess
//
//  Created by Adaya on 07/03/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation
public enum SendVerificationEmailError: CopilotError {
    static func generalError(message: String) -> SendVerificationEmailError {
        return .generalError(debugMessage: message)
    }
    
    case retryRequired(retryInSeconds: Int, debugMessage: String)
    case userAlreadyVerified(debugMessage: String)
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}



public class SendVerificationEmailErrorResolver: ErrorResolver{
    public typealias T = SendVerificationEmailError
    
    public func fromRequiresReloginError(debugMessage: String) -> SendVerificationEmailError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> SendVerificationEmailError {
        return .generalError(debugMessage: "Invalid parameters are not expected: \(debugMessage)")
    }
    
    public func fromGeneralError(debugMessage: String) -> SendVerificationEmailError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> SendVerificationEmailError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> SendVerificationEmailError? {
         if isUserAlreadyVerified(statusCode, reason){
            return .userAlreadyVerified(debugMessage:message)
        }
        return nil
    }
}


extension SendVerificationEmailError : CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Send Verification Email"
    }
    
    public var errorDescription: String? {
        switch self {
        case .requiresRelogin(let debugMessage):
            return requiresReloginMessage(debugMessage: debugMessage)
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        case .retryRequired(let retryInSeconds, let debugMessage):
            return toString("Please retry again in \(retryInSeconds) seconds (\(debugMessage)")
        case .userAlreadyVerified(let debugMessage):
            return toString("User already verified (\(debugMessage))")
        }
    }
}
