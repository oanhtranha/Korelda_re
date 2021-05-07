//
//  AuthenticationService.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
import Moya

enum AuthenticationService {
    case register(email: String, password: String, firstName: String, lastName: String, consents:[String: Bool], deviceDetails: [String: Any])
    case registerAnonymously(consents:[String: Bool], deviceDetails: [String: Any])
    case elevateAnonymous(email: String, password: String, firstName: String, lastName: String)
    case login(email: String, password: String, deviceDetails: [String: Any])
    case refresh(token: String)
    case requireResetPassword(email: String)
    case getPasswordPolicy(userRole: String)
    case approveTermsAndConditions(termsOfUseVersion: String)
    case changePassword(newPassword: String, oldPassword: String)
    case sendVerificationEmail
    case consent(consentsDetails: [String:Bool])
    case consetRefused
}

extension AuthenticationService: TargetType, AccessTokenAuthorizable {
    
    private struct Consts {
        
        static let authPath = "\(NetworkParameters.shared.apiVersion)/auth/"
        
        static let registerPath = Consts.authPath + "register"
        static let registerAnonymouslyPath = Consts.authPath + "anonymousRegistration"
        static let elevateAnonymousPath = Consts.authPath + "elevateAnonymous"
        static let loginPath = Consts.authPath + "login"
        static let refreshTokenPath = Consts.authPath + "refresh"
        static let requireResetPasswordPath = Consts.authPath + "requestResetPassword"
        static let getPasswordPolicyPath = Consts.authPath + "passwordPolicy"
        static let approveTermsPath = Consts.authPath + "approveTermsOfUse"
        static let changePassword = Consts.authPath + "changePassword"
        static let sendVerificationEmail = Consts.authPath + "requestSendVerificationEmail"
        static let consentPath = Consts.authPath + "consent"
        static let consentRefusedPath = Consts.authPath + "consentRefused"
    }
    
    var baseURL: URL {
        return NetworkParameters.shared.baseURL
    }
    
    var path: String {
        switch self {
        case .register(email: _, password: _, firstName: _, lastName: _, consents: _, deviceDetails: _):
            return Consts.registerPath
        case .registerAnonymously(consents: _, deviceDetails: _):
            return Consts.registerAnonymouslyPath
        case .elevateAnonymous(email: _, password: _, firstName: _, lastName: _):
            return Consts.elevateAnonymousPath
        case .login(email: _, password: _, deviceDetails: _):
            return Consts.loginPath
        case .refresh(token: _):
            return Consts.refreshTokenPath
        case .requireResetPassword(email: _):
            return Consts.requireResetPasswordPath
        case .getPasswordPolicy(userRole: _):
            return Consts.getPasswordPolicyPath
        case .approveTermsAndConditions(termsOfUseVersion: _):
            return Consts.approveTermsPath
        case .consent(consentsDetails:  _):
            return Consts.consentPath
        case .consetRefused:
            return Consts.consentRefusedPath
        case .changePassword(_, _):
            return Consts.changePassword
        case .sendVerificationEmail:
            return Consts.sendVerificationEmail
        }
    }
    
    var method: Moya.Method  {
        switch self {
        case .register(email: _, password: _, firstName: _, lastName: _, consents: _, deviceDetails: _),
             .login(email: _, password: _, deviceDetails: _),
             .requireResetPassword(email: _),
             .registerAnonymously(consents: _, deviceDetails: _),
             .elevateAnonymous(email: _, password: _, firstName: _, lastName: _),
             .sendVerificationEmail:
            return .post
        case .getPasswordPolicy(userRole: _):
            return .get
        case .refresh(token: _):
            return .put
        case .approveTermsAndConditions(termsOfUseVersion: _):
            return .post
        case .consent(consentsDetails: _):
            return .post
        case .consetRefused:
            return .post
        case .changePassword(_,_):
            return .post
        }
    }
    
    var authorizationType: AuthorizationType? {
        switch self {
        case .elevateAnonymous(email: _, password: _, firstName: _, lastName: _),
             .approveTermsAndConditions(termsOfUseVersion: _),
             .consent(consentsDetails: _),
             .sendVerificationEmail,
             .changePassword(_, _),
             .consetRefused:
            return .bearer
        default:
            return .none
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .register(email: let email, password: let password, firstName: let firstName, lastName: let lastName, consents: let consents, deviceDetails: let deviceDetails):
            return AuthenticationIntepreter.convertRegisterParamsToDictionary(email: email, password: password, firstName: firstName, lastName: lastName, consents: consents, deviceDetails: deviceDetails)
        case .registerAnonymously(consents: let consents, deviceDetails: let deviceDetails):
            return AuthenticationIntepreter.convertRegisterAnonymouslyParamsToDictionary(consents: consents, deviceDetails: deviceDetails)
        case .elevateAnonymous(email: let email, password: let password, firstName: let firstName, lastName: let lastName):
            return AuthenticationIntepreter.convertElevateAnonymousParamsToDictionary(email: email, password: password, firstName: firstName, lastName: lastName)
        case .login(email: let email, password: let password, deviceDetails: let deviceDetails):
            return AuthenticationIntepreter.convertLoginParamsToDictionary(email: email, password: password, deviceDetails: deviceDetails)
            
        case .refresh(token: let token):
            return AuthenticationIntepreter.convertRefreshParamsToDictionary(token: token)
        case .requireResetPassword(let email):
            return AuthenticationIntepreter.convertRequireResetPasswordParamsToDictionary(email: email)
        case .getPasswordPolicy(let userRole):
            return AuthenticationIntepreter.convertGetPasswordPolicyParamsToDictionary(userRole: userRole)
        case .approveTermsAndConditions(let termsOfUseVersion):
            return AuthenticationIntepreter.convertTermsOfUseParamsToDictionary(termsOfUseVersion: termsOfUseVersion)
        case .consent(consentsDetails: let consentsDetails):
            return AuthenticationIntepreter.convertConsentParamsToDictionary(consentsDetails: consentsDetails)
        case .consetRefused:
            return nil
        case .changePassword(let newPassword, let oldPassword):
            return AuthenticationIntepreter.convertChangePasswordParamsToDictionary(newPassword: newPassword, oldPassword: oldPassword)
        case .sendVerificationEmail:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .register(email: _, password: _, firstName: _, lastName: _, consents: _, deviceDetails: _),
             .registerAnonymously(consents: _, deviceDetails: _),
             .elevateAnonymous(email: _, password: _, firstName: _, lastName: _),
             .login(email: _, password: _, deviceDetails: _),
             .refresh(token: _),
             .requireResetPassword(email: _),
             .approveTermsAndConditions(termsOfUseVersion: _),
             .consent(consentsDetails: _),
             .consetRefused,
             .changePassword(_,_),
             .sendVerificationEmail:
            return JSONEncoding.default
        case .getPasswordPolicy(userRole: _):
            return URLEncoding.default
        }
    }
    
    var task: Task {
        if let params = parameters {
            return .requestParameters(parameters: params, encoding: parameterEncoding)
        } else {
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
