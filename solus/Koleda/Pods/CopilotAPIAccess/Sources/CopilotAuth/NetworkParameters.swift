//
//  NetworkParameters.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 17/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

class NetworkParameters {
    
    static let shared = NetworkParameters()
    
    private var configurationProvider: ConfigurationProvider?
    
    private struct Keys {
        static let dummyAppID = "DummyAppID"
        static let dummyURL = "www.thisisnotreal.website"
    }        
    
    let apiVersion = "v4"
    
    func setConfigurationProvider(_ configurationProvider: ConfigurationProvider) {
        if self.configurationProvider == nil {
            self.configurationProvider = configurationProvider
        }
    }
   
    private var environmentUrl: String? {
        var pathResult: String?
        
        guard let copilotEnvironmentUrl = configurationProvider?.baseUrl else {
            ZLogManagerWrapper.sharedInstance.logError(message: "Couldn't find Path in Copilot-Info.plist")
            return pathResult
        }
        
        pathResult = copilotEnvironmentUrl
        
        return pathResult
    }
    
    
    var baseURL: URL {
        var url: URL?
        
        if let environmentUrl = environmentUrl {
            
            //Create the URL
            if let baseURL = URL(string: environmentUrl) {
                url = baseURL
            }
            else {
                ZLogManagerWrapper.sharedInstance.logError(message: "URL wasn't created from base URL: \(environmentUrl)")
            }
        }
        else {
            ZLogManagerWrapper.sharedInstance.logError(message: "URL wasn't created. Path not found.")
        }
        
        if let url = url {
            return url
        }
        else {
            ZLogManagerWrapper.sharedInstance.logError(message: "Path is missing from Copilot-Info.plist, returning dummy URL")
            return URL(string: Keys.dummyURL)!
        }
    }
    
    var appID: String {
        var appID: String?
        
        if let appIDFromParams = configurationProvider?.applicationId {
            appID = appIDFromParams
        }
        
        guard let appIDResult = appID else {
            ZLogManagerWrapper.sharedInstance.logError(message: "AppID is missing from Copilot-Info.plist, returning dummy AppID")
            return "DummyAppID"
        }
        
        return appIDResult
    }
    
    private init() {
        
    }
}
