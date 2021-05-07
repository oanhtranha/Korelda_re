//
//  ApproveTermsOfUseError.swift
//  CopilotAuth
//
//  Created by Adaya on 13/12/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

public enum ApproveTermsOfUseError : CopilotError {
    static func generalError(message: String) -> ApproveTermsOfUseError {
        return .generalError(debugMessage: message)
    }
    
    case invalidParameters(debugMessage: String)
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class ApproveTermsOfUseErrorResolver : ErrorResolver{
    public typealias T = ApproveTermsOfUseError
    
    public func fromRequiresReloginError(debugMessage: String) -> ApproveTermsOfUseError {
        return .requiresRelogin(debugMessage:debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> ApproveTermsOfUseError {
        return .invalidParameters(debugMessage: debugMessage)
    }
    
    public func fromGeneralError(debugMessage: String) -> ApproveTermsOfUseError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> ApproveTermsOfUseError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> ApproveTermsOfUseError? {
        if isMarkedForDeletion(statusCode, reason){
            return .requiresRelogin(debugMessage: "Marked for deletion")
        }
        return nil
    }
}





extension ApproveTermsOfUseError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Approve Terms of Use"
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
