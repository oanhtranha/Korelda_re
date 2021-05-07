//
//  BundleConfigurationProvider.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 29/10/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

enum ManageType: String {
    case yourOwn
    case copilotConnect
}

internal class BundleConfigurationProvider: ConfigurationProvider {
    
    let baseUrl: String?
    let applicationId: String?
    let isGdprCompliant: Bool?
    let manageType: ManageType
    let appVersion: String
    
    private struct Consts {
        static let plistName = "Copilot-Info"
        static let plistType = "plist"
        static let authenticationParams = "Authentication Params"
        static let environmentUrl = "ENVIRONMENT_URL"
        static let applicationId = "APPLICATION_ID"
        static let isGDPRCompliant = "IS_GDPR_COMPLIANT"
        static let manageType = "MANAGE_TYPE"
        static let yourOwn = "yourOwn"
        static let copilotConnect = "copilotConnect"
    }
    
    init(bundle: Bundle = .main) {
        
        guard let plistFile = bundle.path(forResource: Consts.plistName, ofType: Consts.plistType) else {
            fatalError("Copilot-Info.plist file not found.")
        }
        
        let copilotConfiguration: [String : Any]? = NSDictionary(contentsOfFile: plistFile) as? [String: Any]
        let authenticationParams: [String : Any]? = copilotConfiguration?[Consts.authenticationParams] as? [String : Any]
        
        // is GDPR Compliant
        isGdprCompliant = copilotConfiguration?[Consts.isGDPRCompliant] as? Bool
        
        // App ID
        applicationId = authenticationParams?[Consts.applicationId] as? String
        
        // Base URL
        baseUrl = authenticationParams?[Consts.environmentUrl] as? String
        
        // Manage Type
        let configurationManageType = copilotConfiguration?[Consts.manageType] as? String
        guard let copilotManageType = configurationManageType else {
            fatalError("Copilot-Info.plist file is missing the mandatory `MANAGE_TYPE` key, it should point to a String value.")
        }
        
        if copilotManageType.lowercased() == Consts.yourOwn.lowercased() {
            manageType = .yourOwn
        } else if copilotManageType.lowercased() == Consts.copilotConnect.lowercased() {
            manageType = .copilotConnect
        } else {
            fatalError("Copilot-Info.plist file is missing the mandatory `MANAGE_TYPE` key, it should point to a String value `YourOwn` or `CopilotConnect`.")
        }
        
        // App version
        var appVersionBundle = bundle
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            // Code only executes when tests are running
            appVersionBundle = Bundle(for: type(of: self))
        }
        #endif
        self.appVersion = appVersionBundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}
