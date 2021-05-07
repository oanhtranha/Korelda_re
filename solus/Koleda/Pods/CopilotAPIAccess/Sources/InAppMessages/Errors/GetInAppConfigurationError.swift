//
//  GetInAppConfigurationError.swift
//  ZemingoBLELayer
//
//  Created by Elad on 30/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

public enum GetInAppConfigurationError: Error {
    case requiresRelogin(debugMessage: String)
    case generalError(debugMessage: String)
    case connectivityError(debugMessage: String)
}

public class FetchInAppConfigurationErrorResolver: ErrorResolver {
    public typealias T = GetInAppConfigurationError
    
    public func fromRequiresReloginError(debugMessage: String) -> GetInAppConfigurationError {
        return .requiresRelogin(debugMessage: debugMessage)
    }
    
    public func fromInvalidParametersError(debugMessage: String) -> GetInAppConfigurationError {
        return .generalError(debugMessage: "Unexpected invalid parameters \(debugMessage)")
    }
    
    public func fromGeneralError(debugMessage: String) -> GetInAppConfigurationError {
        return .generalError(debugMessage: debugMessage)
    }
    
    public func fromConnectivityError(debugMessage: String) -> GetInAppConfigurationError {
        return .connectivityError(debugMessage:debugMessage)
    }
    
    public func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> GetInAppConfigurationError? {
        return nil
    }
}
