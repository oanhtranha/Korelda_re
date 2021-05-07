//
//  ConsumableUsageAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Richard Houta on 10/10/2018.
//  Copyright © 2018 Zemingo. All rights reserved.
//

import Foundation

public struct ConsumableUsageAnalyticsEvent: AnalyticsEvent {
    
    private let name: String = "consumable_usage"
    private let thingIdParamKey: String = "thing_id"
    private let consumableTypeParamKey: String = "consumable_type"
    private let thingId: String
    private let consumableType: String
    private let screenName: String
    
    public init(thingId: String, consumableType: String, screenName: String) {
        self.thingId = thingId
        self.consumableType = consumableType
        self.screenName = screenName
    }
    
    public var customParams: Dictionary<String, String> {
        return [AnalyticsConstants.screenNameKey: screenName, thingIdParamKey: thingId, consumableTypeParamKey: consumableType]
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .Thing
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All, .Engagement]
    }
}
