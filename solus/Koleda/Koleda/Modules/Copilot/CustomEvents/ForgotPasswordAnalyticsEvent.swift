//
//  ForgotPasswordAnalyticsEvent.swift
//  Koleda
//
//  Created by Oanh Tran on 9/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import CopilotAPIAccess

struct ForgotPasswordAnalyticsEvent: AnalyticsEvent {
    
    private let email: String
    private let screenName: String
    
    init(email:String, screenName: String) {
        self.email = email
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["email" : email,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "forgot_password"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

