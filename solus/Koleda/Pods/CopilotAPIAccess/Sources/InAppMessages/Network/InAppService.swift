//
//  InAppService.swift
//  CopilotAPIAccess
//
//  Created by Elad on 22/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import Moya


internal enum InAppService {
    case getInAppMessages(authType: AuthorizationType?)
    case postMessageDisplayed(messageId: String, authType: AuthorizationType?)
    case getInAppConfiguration(os: String, appVersion: String, sdkVerion: String)
}

extension InAppService: TargetType, AccessTokenAuthorizable {
    private struct Consts {
        static let servicePath = "\(NetworkParameters.shared.apiVersion)/inapp"
        
        static let iamMessagesPathSuffix = "/messages"
        static let iamMessageDisplayedPathSuffix = "/displayed"
        static let iamConfiguration = "/config"
        
        //parameters
        static let osParam = "osType"
        static let appVersionParam = "appVersion"
        static let sdkVersionParam = "sdkVersion"
        
    }
    
    public var baseURL: URL {
        return NetworkParameters.shared.baseURL
    }
    
    var authorizationType: AuthorizationType? {
        switch self {
        case .getInAppMessages(let authType),
             .postMessageDisplayed(_, let authType):
            return authType
        case .getInAppConfiguration:
            return nil
        }
    }
    
    public var path: String {
        switch self {
        case .getInAppMessages:
            return Consts.servicePath + Consts.iamMessagesPathSuffix
        case .postMessageDisplayed(let messageId, _):
            return Consts.servicePath + Consts.iamMessagesPathSuffix + "/" + messageId + Consts.iamMessageDisplayedPathSuffix
        case .getInAppConfiguration:
            return Consts.servicePath + Consts.iamConfiguration
        }
    }
    
    public var method: Moya.Method  {
        switch self {
        case .getInAppMessages, .getInAppConfiguration:
            return .get
        case .postMessageDisplayed( _ , _):
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getInAppMessages, .postMessageDisplayed:
            return nil
        case .getInAppConfiguration(let os, let appVersion, let sdkVerion):
            return [Consts.osParam: os, Consts.appVersionParam: appVersion, Consts.sdkVersionParam: sdkVerion]
        }
    
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self {
        case .getInAppMessages, .postMessageDisplayed:
            return JSONEncoding.default
        case .getInAppConfiguration:
            return URLEncoding.default
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        if let params = parameters {
            return .requestParameters(parameters: params, encoding: parameterEncoding)
        } else {
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
}
