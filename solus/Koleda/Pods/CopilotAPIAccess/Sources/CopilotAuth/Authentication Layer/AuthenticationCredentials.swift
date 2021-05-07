//
//  AuthenticationCredentials.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 03/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

struct AuthenticationCredentials {
    
    private struct Constants {
        static let accessTokenKey = "accessToken"
        static let refreshTokenKey = "refreshToken"
        static let expirationTimeKey = "expiresIn"
        static let tokenTypeKey = "tokenType"
    }
    
    let accessToken: String
    let refreshToken: String
    let expiration: TimeInterval
    let tokenType: String
    
    
    init?(withDictionary dictionary: [String: Any]) {
        guard let accessToken = dictionary[Constants.accessTokenKey] as? String,
            let refreshToken = dictionary[Constants.refreshTokenKey] as? String,
            let expiration = dictionary[Constants.expirationTimeKey] as? TimeInterval,
            let tokenType = dictionary[Constants.tokenTypeKey] as? String else {
                ZLogManagerWrapper.sharedInstance.logError(message: "unable to parse dictionary to authentication credentials with dict: \(dictionary)")
                return nil
        }
        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiration = expiration
        self.tokenType = tokenType
        
    }
}
