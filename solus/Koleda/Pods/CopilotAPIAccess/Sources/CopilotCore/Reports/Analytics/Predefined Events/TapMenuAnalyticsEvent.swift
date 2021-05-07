//
//  TapMenuAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct TapMenuAnalyticsEvent: AnalyticsEvent {
    
    var screenName: String?
    
    let name = "tap_menu"
    
    public init(screenName: String? = nil) {
        self.screenName = screenName
    }

    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        
        var params = Dictionary<String, String>()
        
        if let screenName = screenName {
            params.updateValue(screenName, forKey: AnalyticsConstants.screenNameKey)
        }
        
        return params
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

