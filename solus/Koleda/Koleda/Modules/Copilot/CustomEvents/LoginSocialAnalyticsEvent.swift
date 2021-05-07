//
//  LoginSocialAnalyticsEvent.swift
//  Koleda
//
//  Created by Oanh Tran on 9/3/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import CopilotAPIAccess

struct LoginSocialAnalyticsEvent: AnalyticsEvent {
    
    private let provider: String
    private let token: String
    private let zoneId: String
    private let screenName: String
    
    init(provider:String, token: String, zoneId: String, screenName: String) {
        self.provider = provider
        self.token = token
        self.zoneId = zoneId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["provider" : provider,
                "token" : token,
                "zoneId" : zoneId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "login_social"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
