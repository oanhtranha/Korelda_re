//
//  ThingConnectedAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct ThingConnectedAnalyticsEvent: AnalyticsEvent {
    
    let name = "thing_connected"
    let thingIDParamKey = "thing_id"
    
    var screenName: String?
    var thingID: String
    
    public init(thingID: String, screenName: String? = nil) {
        self.screenName = screenName
        self.thingID = thingID
    }
    
    //MARK: AnalyticsEvent
    
    public var customParams: Dictionary<String, String> {
        var params = [thingIDParamKey : thingID]
        
        if let screenName = screenName {
            params.updateValue(screenName, forKey: AnalyticsConstants.screenNameKey)
        }
        
        return params
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .Thing
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All, .Engagement, .Main]
    }
}
