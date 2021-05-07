//
//  GetInAppDataError.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

public enum GetInAppMessagesError: Error {
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class FetchInAppMessagesErrorResolver: ErrorResolver {
    public typealias T = GetInAppMessagesError
    
    public func fromRequiresReloginError(debugMessage: String) -> GetInAppMessagesError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> GetInAppMessagesError {
        return .generalError(debugMessage: "Unexpected invalid parameters \(debugMessage)")
    }
    
    public func fromGeneralError(debugMessage: String) -> GetInAppMessagesError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> GetInAppMessagesError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> GetInAppMessagesError? {
        return nil
    }
}



extension GetInAppMessagesError: CopilotLocalizedError {
    public func errorPrefix() -> String {
        return "Fetch In App Message Data"
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
