
//
//  JoinHomeAnalyticsEvent.swift
//  Koleda
//
//  Created by Oanh Tran on 9/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import CopilotAPIAccess

struct JoinHomeAnalyticsEvent: AnalyticsEvent {
    
    private let name: String
    private let email: String
    private let homeId: String
    private let screenName: String
    
    init(name:String, email: String, homeId: String, screenName: String) {
        self.name = name
        self.email = email
        self.homeId = homeId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["name" : name,
                "email" : email,
                "homeId" : homeId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "join_home"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
