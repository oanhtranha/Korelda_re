//
//  UserGeneralParametersRepository.swift
//  User
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

class CopilotUserGeneralParametersRepository: UserGeneralParametersRepository {
    
    var userId: String?
    private let signUpMethod: CredentialsType
    private let userEmail: String?
    
    private struct Constants {
        static let userEmailParamKey = "user_email"
        static let signUpMethodParamKey = "sign_up_method"
    }
    
    init(signUpMethod: CredentialsType, userId: String? = nil, userEmail: String? = nil) {
        self.signUpMethod = signUpMethod
        self.userId = userId
        self.userEmail = userEmail
    }
    
    var additionalParams: [String: String] {
        guard let userEmail = userEmail else {
            return [Constants.signUpMethodParamKey : signUpMethod.rawValue]
        }
        return [Constants.userEmailParamKey : userEmail ,Constants.signUpMethodParamKey : signUpMethod.rawValue]
    }
    
    var additionalParamsKeys: [String] {
        return [Constants.userEmailParamKey, Constants.signUpMethodParamKey]
    }
}
