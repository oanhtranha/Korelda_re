//
//  ConsentRefusedError.swift
//  User
//
//  Created by Tom Milberg on 13/05/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public enum ConsentRefusedError : CopilotError {
    static func generalError(message: String) -> ConsentRefusedError {
        return .generalError(debugMessage: message)
    }
    
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class ConsentRefusedErrorResolver : ErrorResolver{
    public typealias T = ConsentRefusedError
    
    public func fromRequiresReloginError(debugMessage: String) -> ConsentRefusedError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> ConsentRefusedError {
        return .generalError(debugMessage: "Unexpected invalid parameters \(debugMessage)")
    }
    
    public func fromGeneralError(debugMessage: String) -> ConsentRefusedError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> ConsentRefusedError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> ConsentRefusedError? {
        return nil
    }
}





extension ConsentRefusedError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Consent Refused"
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
