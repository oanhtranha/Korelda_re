//
//  SuccessfulElevateAnonymousAnalyticEvent.swift
//  CopilotAPIAccess
//
//  Created by Richard Houta on 08/10/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

public struct SuccessfulElevateAnonymousAnalyticEvent: AnalyticsEvent {
    
    let name: String = "successful_elevate_anonymous"
    let screenName: String = "sign_up"
    
    public init() {}
    
    public var customParams: Dictionary<String, String> {
        return [AnalyticsConstants.screenNameKey : screenName]
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .Server
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All, .Main, .Engagement]
    }
}
