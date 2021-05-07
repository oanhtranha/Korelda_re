//
//  FetchPasswordRulesPolicyError.swift
//  CopilotAuth
//
//  Created by Shachar Silbert on 28/08/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

public enum FetchPasswordRulesPolicyError: CopilotError {
    static func generalError(message: String) -> FetchPasswordRulesPolicyError {
        return .generalError(debugMessage: message)
    }
    
    case connectivityError(debugMessage: String)
    case generalError(debugMessage: String)
}
public class FetchPasswordRulesPolicyErrorResolver : ErrorResolver{
    public func fromRequiresReloginError(debugMessage: String) -> FetchPasswordRulesPolicyError {
        return .generalError(debugMessage: "Unexpected unauthorized exception")
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> FetchPasswordRulesPolicyError {
        return .generalError(debugMessage: "Unexpected invalidParameters exception")
    }
    
    public func fromGeneralError(debugMessage: String) -> FetchPasswordRulesPolicyError {
        return .generalError(debugMessage:debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> FetchPasswordRulesPolicyError {
        return .connectivityError(debugMessage: debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> FetchPasswordRulesPolicyError? {
        return nil
    }
    
    public typealias T = FetchPasswordRulesPolicyError
}
extension FetchPasswordRulesPolicyError : CopilotLocalizedError{
    public func errorPrefix() -> String {
        return "Fetch Password Rules Policy"
    }
    
    public var localizedDescription: String{
        switch(self){
        case .connectivityError(let debugMessage):
            return connectivityErrorMessage(debugMessage: debugMessage)
        case .generalError(let debugMessage):
            return generalErrorMessage(debugMessage: debugMessage)
        }
    }
}


