//
//  ScreenLoadAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 09/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public class ScreenLoadAnalyticsEvent: AnalyticsEvent {
    
    fileprivate let screenName: String
    
    public init(screenName: String) {
        self.screenName = screenName
    }
    
    public var customParams: Dictionary<String, String> {
        return [AnalyticsConstants.screenNameKey : screenName]
    }
    
    public var eventName: String {
        return AnalyticsConstants.screenLoadEventName
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .User
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
