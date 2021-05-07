//
//  ServerError.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

public enum ServerError: Error {
    case authorizationFailure
    case validationError(message: String)
    case copilotError(statusCode: Int, reason: String, message: String)
    case internalServerError(message: String)
    case unknown(statusCode: Int, message: String)
    case communication(error: Error)
    case generalError(message: String)
    
    
    fileprivate struct Constants {
        static let conflict = 409
        static let validationError = 400
        static let validationErrorReason = "common.missingFields"
        static let unauthorized = 401
        static let unauthorizedReason = "auth.unauthorized"
        static let internalServerError = 500
        static let internalServerErrorReason = "util.internalError"
        static let reasonKey = "reason"
        static let errorMessage = "errorMessage"
        static let entityNotFound = 404
        static let entityNotFoundReason = "util.entityNotFound"
        static let fobidden = 403
        static let forbiddenReason = "util.operationForbidden"
        static let markedForDeletion = 403
        static let markedForDeletionReason = "auth.markedForDeletion"
        static let invalidApplicationId = 403
        static let invalidApplicationIdReason = "auth.applicationIdIsNotValid"
        static let passwordPolicyViolation = 400
        static let passwordPolicyViolationReason = "auth.passwordPolicyViolation"
        static let userAlreadyExists = conflict
        static let userAlreadyExistsReason = "auth.userAlreadyExists"
        static let invalidPermissions = 403
        static let invalidPermissionsReason = "auth.invalidPermissions"
        static let passwordResetFailedReason = "auth.passwordResetFailed"//(403 / “auth.passwordResetFailed”)
        static let invalidEmail = 400
        static let invalidEmailReason = "auth.invalidEmail"
        static let userAlreadyVerifiedReason = "auth.userAlreadyVerified"
        static let emailNotVerified = 412
        static let emailNotVerifiedReason = "auth.emailNotVerified"
    }
    
    
    static func isMarkedForDeletionError (_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.markedForDeletion && reason == ServerError.Constants.markedForDeletionReason
    }
    static func serverErrorFromStatusCode(_ statusCode: Int, _ json: [String: Any]?) -> ServerError? {
        if(statusCode<400){
            return nil;
        }
        guard let errorMap = json else{
            return .unknown(statusCode: statusCode, message: "No additional information provided")
        }
        guard let copilotReason = errorMap[Constants.reasonKey] as? String else{
            let msgOptional = errorMap[Constants.errorMessage] as? String
            let msg = msgOptional ?? "No additional information provided"
            return .unknown(statusCode: statusCode, message: msg)
        }
        
        if statusCode == Constants.unauthorized && copilotReason == Constants.unauthorizedReason{
            return .authorizationFailure
        }
        
        let errorMessageOptional = errorMap[Constants.errorMessage] as? String
        let errorMessage = errorMessageOptional ?? "No additional information provided"
        
        if statusCode == Constants.internalServerError && copilotReason == Constants.internalServerErrorReason{
            return .internalServerError(message: errorMessage)
        }
        
        if statusCode == Constants.validationError && copilotReason == Constants.validationErrorReason{
            return .validationError(message: errorMessage)
        }
        
        return .copilotError(statusCode: statusCode, reason: copilotReason, message: errorMessage)
    }
    
    func asDetailedMessage() -> String{
        return errorDescription!;
    }
}

// MARK: - Error Descriptions

extension ServerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .internalServerError(let message):
            return "Internal Server Error: \(message)"
        case .authorizationFailure:
            return "Server failed to authenticate the request"
        case .validationError(let message):
            return "Server validation failed due to \(message )"
        case .copilotError(let statusCode, let reason, let message):
            return "Server error occured with status \(statusCode), reason: \(reason) and message: \(message )"
        case .unknown(let statusCode, let message):
            return "Server error occured with status \(statusCode) and message: \(message)"
        case .communication(error: let communicationError):
            return createErrorDescription(originalErrorDescription: communicationError.localizedDescription, defaultDescription: "communication error - No additional information provided")
        case .generalError(message: let generalErrorMessage):
            return createErrorDescription(originalErrorDescription: generalErrorMessage, defaultDescription: "general error - No additional information provided")
        }
    }
    
    private func createErrorDescription(originalErrorDescription: String?, defaultDescription: String) -> String {
        var description: String
        
        if let origDesc = originalErrorDescription {
            description = origDesc
        }
        else {
            description = defaultDescription
        }
        
        return description
    }
}


public protocol ErrorResolver{
    associatedtype T
    func resolve(_ serverError: ServerError) -> T
    func fromRequiresReloginError(debugMessage: String) -> T
    func fromInvalidParametersError(debugMessage: String) -> T
    func fromGeneralError(debugMessage: String) -> T
    func fromConnectivityError(debugMessage: String) -> T
    func fromTypeSpecificError(_ statusCode: Int, _ reason: String, _ message: String) -> T?
}

public extension ErrorResolver{
    func resolve(_ serverError: ServerError) -> T{
        switch serverError {
        case .authorizationFailure:
            return fromRequiresReloginError(debugMessage: "Authentication failure")
        case .validationError(let message):
            return fromInvalidParametersError(debugMessage: message)
        case .communication(_):
            return fromConnectivityError(debugMessage: serverError.asDetailedMessage())
        case .copilotError(let statusCode, let reason, let message):
            if let error = fromTypeSpecificError(statusCode, reason, message){
                return error
            }
            fallthrough
        case .internalServerError(_):
            fallthrough
        case .unknown(_,_):
            fallthrough
        case .generalError(_):
            return fromGeneralError(debugMessage: serverError.asDetailedMessage())
            
        }
        
    }
    
    
    func isEntityNotFound(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.entityNotFound && reason == ServerError.Constants.entityNotFoundReason
    }
    
    func isOperationForbidden(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.fobidden && reason == ServerError.Constants.forbiddenReason
    }
    
    func isMarkedForDeletion (_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.markedForDeletion && reason == ServerError.Constants.markedForDeletionReason
    }
    
    func isInvalidApplicationId(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.invalidApplicationId && reason == ServerError.Constants.invalidApplicationIdReason
    }
    
    func isUserAlreadyExists(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.userAlreadyExists && reason == ServerError.Constants.userAlreadyExistsReason
    }
    
    func isPasswordPolicyViolation(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.passwordPolicyViolation && reason == ServerError.Constants.passwordPolicyViolationReason
    }
    
    func isPasswordResetFailed(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.fobidden && reason == ServerError.Constants.passwordResetFailedReason
    }
    
    func isInvalidPermissions(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.invalidPermissions && reason == ServerError.Constants.invalidPermissionsReason
    }
    
    func isInvalidParameters(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.validationError && reason == ServerError.Constants.validationErrorReason
    }

    func isInvalidEmail(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.invalidEmail && reason == ServerError.Constants.invalidEmailReason
    }
    func isUserAlreadyVerified(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.conflict && reason == ServerError.Constants.userAlreadyVerifiedReason
    }
    func isEmailNotVerified(_ statusCode: Int, _ reason: String) -> Bool{
        return statusCode == ServerError.Constants.emailNotVerified && reason == ServerError.Constants.emailNotVerifiedReason
    }
}


public protocol CopilotLocalizedError : LocalizedError{
    //associatedtype T
    func errorPrefix() -> String
    func invalidParametersMessage(debugMessage: String) -> String
    func requiresReloginMessage(debugMessage: String) -> String
    func generalErrorMessage(debugMessage: String) -> String
    func connectivityErrorMessage(debugMessage: String) -> String
}

public extension CopilotLocalizedError{
    
    func invalidParametersMessage(debugMessage: String) -> String{
        return toString("Invalid Parameters: \(debugMessage)")
    }
    func requiresReloginMessage(debugMessage: String) -> String{
        return toString("Requires Login: \(debugMessage)")
    }
    func generalErrorMessage(debugMessage: String) -> String{
        return toString("General error: \(debugMessage)")
    }
    func connectivityErrorMessage(debugMessage: String) -> String{
        return toString("Connectivity error: \(debugMessage)")
    }
    
    func toString(_ st: String) -> String{
        return "[\(errorPrefix())] \(st)"
    }
}




