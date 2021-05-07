//
//  LogoutAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct LogoutAnalyticsEvent: AnalyticsEvent {
    
    let name = "logout"
    let screenName = "settings"
    
    public init() {}
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        return [AnalyticsConstants.screenNameKey : eventName]
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .User
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
