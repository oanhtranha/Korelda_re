//
//  WSError.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import SwiftyJSON

enum GenericError: Error {
    case error(String)
}

extension GenericError {
    init(_ string: String) {
        self = .error(string)
    }
}

enum WSError: Error, LocalizedError {
    case empty
    case general
    case loginSessionExpired
    case locationServicesUnavailable
    case failedToParseJsonData
    case failedUpdateRoom
    case failedAddRoom
    case deviceExisted
    case emailExisted
    case emailNotExisted
	case failedAddHome
	case hiddenAppleEmail
    case emailNotAvailable
    case homeIDInvalid
    case emailNotInvited
    case emailInvalid
    case emailSimilar
    case emailGuest
    case emailMaster
    case userNotFound
    
    var errorDescription: String? {
        guard let description = localizedErrors[self] else {
            return "ERROR_TITLE".app_localized
        }
        return description
    }
}


extension WSError {
    init?(responseData: Data?) {
        guard let data = responseData else {
            return nil
        }
        
        guard let json = try? JSON(data: data), let errorCode = json["errorCode"].string, let error = WSError(JSONValue: errorCode) else {
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            log.info("Can't construct WSError from JSON: \(jsonString))")
            return nil
        }
        
        self = error
    }
    
    static func error(from responseData: Data?, defaultError: WSError) -> WSError {
        return WSError(responseData: responseData) ?? defaultError
    }
}

extension WSError {
    
    init?(JSONValue rawValue: String) {
        switch rawValue {
        case "BAD_REQUEST":
            self = .empty
        case "DEVICE_EXISTED":
            self = .deviceExisted
        case "EMAIL_NOT_EXISTED":
            self = .emailNotExisted
		case "HIDDEN_APPLE_EMAIL":
			self = .hiddenAppleEmail
        case "EMAIL_EXISTED":
            self = .emailNotAvailable
        case "HOME_ID_INVALID", "HOME_NOT_CREATED":
            self = .homeIDInvalid
        case "EMAIL_IS_NOT_INVITED":
            self = .emailNotInvited
        case "EMAIL_INVALID":
            self = .emailInvalid
        case "EMAIL_SIMILAR":
            self = .emailSimilar
        case "EMAIL_MASTER":
            self = .emailMaster
        case "EMAIL_GUEST":
            self = .emailGuest
        default:
            return nil
        }
    }
    
    static func error(fromJSONValue rawValue: String, defaultError: WSError) -> WSError {
        return WSError(JSONValue: rawValue) ?? defaultError
    }
    
}

private extension WSError {
    var localizedErrors: [WSError : String] {
        return [.empty: "PLACEHOLDER_ERROR_MESSAGE".app_localized,
                .general: "ERROR_GENERAL".app_localized,
                .loginSessionExpired: "LOGIN_SESSSION_EXPIRED".app_localized,
                .failedUpdateRoom : "FAILED_TO_UPDATE_ROOM".app_localized,
                .deviceExisted : "DEVICE_EXISTED_MESSAGE".app_localized,
                .emailExisted: "EMAIL_EXISTED_MESSAGE".app_localized,
                .emailNotExisted: "EMAIL_NOT_EXISTED_MESSAGE".app_localized,
				.hiddenAppleEmail: "SHARE_APPLE_EMAIL_REQUIRED_MESSAGE".app_localized,
                .emailNotAvailable: "EMAIL_NOT_AVAILABLE_MESSAGE".app_localized,
                .homeIDInvalid: "HOME_ID_INVALID_MESSAGE".app_localized,
                .emailNotInvited: "EMAIL_IS_NOT_INVITED_MESSAGE".app_localized,
                .emailInvalid: "EMAIL_INVALID_MESSAGE".app_localized,
                .emailSimilar: "EMAIL_SIMILAR_MESSAGE".app_localized,
                .emailMaster: "EMAIL_MASTER_MESSAGE".app_localized,
                .emailGuest: "EMAIL_GUEST_MESSAGE".app_localized,
                .userNotFound: "USER_NOT_FOUND_MESSAGE".app_localized ]
    }
}

