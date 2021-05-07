//
//  AuthenticationIntepreter.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

struct AuthenticationIntepreter {
    
    private struct ParameterConsts {
        
        static let userRoleKey = "userRole"
        
        static let authenticationDetailsDictKey = "authenticationDetails"
        static let deviceDetailsDictKey = "deviceDetails"
        static let setUserDetailsDictKey = "setUserDetails"
        static let consentDetailsDictKey = "consent"
        
        static let emailKey = "email"
        static let passwordKey = "password"
        static let applicationIdKey = "applicationId"
        static let applicationIdVal = NetworkParameters.shared.appID
        
        static let firstNameKey = "firstName"
        static let lastNameKey = "lastName"
        
        static let refreshTokenKey = "refreshToken"
        
        static let userEmailKey = "userEmail"
        static let termsOfUseVersion = "termsOfUseVersion"
        
        static let consents = "consents"
        static let consentItemName = "key"
        static let consentItemValue = "value"
        
        static let changePasswordNewPassword = "password"
        static let changePasswordOldPassword = "oldPassword"
    }
    
    private struct IntepreterConsts {
        static let accessTokenKey = "accessToken"
        static let refreshTokenKey = "refreshToken"
        static let expiresInKey = "expiresIn"
        static let tokenTypeKey = "tokenType"
    }
    
    //The parameters are just like login with extra first name and last name parameters
    
    static func convertRegisterParamsToDictionary(email: String, password: String, firstName: String, lastName: String, consents:[String: Bool],  deviceDetails: [String: Any]) -> [String: Any] {
        
        var params = AuthenticationIntepreter.convertLoginParamsToDictionary(email: email, password: password, deviceDetails: deviceDetails)
        let userDetailsDictionary = [ParameterConsts.firstNameKey: firstName,
                                     ParameterConsts.lastNameKey: lastName]
        let consentsDictionary = convertConsentParamsToDictionary(consentsDetails: consents)
        
        params[ParameterConsts.setUserDetailsDictKey] = userDetailsDictionary
        params[ParameterConsts.consentDetailsDictKey] = consentsDictionary
        
        return params
    }
    
    static func convertRegisterAnonymouslyParamsToDictionary(consents:[String: Bool],  deviceDetails: [String: Any]) -> [String: Any] {
        var params: [String: Any] = [:]
        let consentsDictionary = convertConsentParamsToDictionary(consentsDetails: consents)
        params[ParameterConsts.applicationIdKey] = ParameterConsts.applicationIdVal
        params[ParameterConsts.consentDetailsDictKey] = consentsDictionary
        params[ParameterConsts.deviceDetailsDictKey] = deviceDetails
        return params
    }
    
    static func convertElevateAnonymousParamsToDictionary(email: String, password: String, firstName: String, lastName: String) -> [String: Any] {
        var params: [String: Any] = [:]
        let authenticationDetails = convertAuthenticationDetailsParamsToDictionary(email: email, password: password)
        let userDetailsDictionary = [ParameterConsts.firstNameKey: firstName,
                                     ParameterConsts.lastNameKey: lastName]
        params[ParameterConsts.authenticationDetailsDictKey] = authenticationDetails
        params[ParameterConsts.setUserDetailsDictKey] = userDetailsDictionary
        return params
    }
    
    private static func convertAuthenticationDetailsParamsToDictionary(email: String, password: String) -> [String: Any] {
        let authenticationDetails = [ParameterConsts.emailKey: email,
                                     ParameterConsts.passwordKey: password,
                                     ParameterConsts.applicationIdKey: ParameterConsts.applicationIdVal]
        return authenticationDetails
    }
    
    static func convertLoginParamsToDictionary(email: String, password: String, deviceDetails: [String: Any]) -> [String: Any] {
        let authenticationDetails = convertAuthenticationDetailsParamsToDictionary(email: email, password: password)
        
        return [ParameterConsts.authenticationDetailsDictKey: authenticationDetails,
                ParameterConsts.deviceDetailsDictKey: deviceDetails]
    }
    
    static func convertRefreshParamsToDictionary(token: String)  -> [String: Any] {
        return [ParameterConsts.refreshTokenKey : token]
    }
    
    static func convertRequireResetPasswordParamsToDictionary(email: String)  -> [String: Any] {
        return [ParameterConsts.userEmailKey: email]
    }
    
    static func convertGetPasswordPolicyParamsToDictionary(userRole: String) -> [String: Any] {
        return [ParameterConsts.userRoleKey: userRole]
    }
    
    static func convertTermsOfUseParamsToDictionary(termsOfUseVersion : String) -> [String: Any] {
        return [ParameterConsts.termsOfUseVersion: termsOfUseVersion]
    }
    
    static func convertConsentParamsToDictionary(consentsDetails: [String: Bool]) -> [String: Any] {
        var consentsItems : [[String: Any]] = []
        for (k,v) in consentsDetails {
            consentsItems.append([ParameterConsts.consentItemName: k, ParameterConsts.consentItemValue: v])
        }
        return [ParameterConsts.consents: consentsItems]
    }
    
    static func convertChangePasswordParamsToDictionary(newPassword: String, oldPassword: String) -> [String: Any]{
        return [
            ParameterConsts.changePasswordNewPassword: newPassword,
            ParameterConsts.changePasswordOldPassword: oldPassword
        ]
    }
}
