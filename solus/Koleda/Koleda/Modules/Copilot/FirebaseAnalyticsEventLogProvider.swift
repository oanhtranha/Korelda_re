//
//  FirebaseAnalyticsEventLogProvider.swift
//  Koleda
//
//  Created by Oanh Tran on 8/27/20.
//  Copyright © 2020 koleda. All rights reserved.
//
import Foundation
import Firebase
import FirebaseAnalytics
import CopilotAPIAccess

class FirebaseAnalyticsEventLogProvider: EventLogProvider {
    
    func enable() {
        // No implementation
    }
    
    func disable() {
        // No implementation
    }
    
    func setUserId(userId:String?){
        Analytics.setUserID(userId)
    }
    
    func transformParameters(parameters: Dictionary<String, String>) -> Dictionary<String, String> {
        return parameters
    }
    
    func logCustomEvent(eventName: String, transformedParams: Dictionary<String, String>) {
        Analytics.logEvent(eventName, parameters: transformedParams)
    }
    
    var providerName: String {
        return "FirebaseAnalyticsEventLogProvider"
    }
    
    var providerEventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
