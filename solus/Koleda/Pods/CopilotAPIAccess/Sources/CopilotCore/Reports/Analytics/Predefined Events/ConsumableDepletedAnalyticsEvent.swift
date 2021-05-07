//
//  ConsumableDepletedAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 23/07/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct ConsumableDepletedAnalyticsEvent: AnalyticsEvent {
    
    private let screenName: String?
    private let thingId: String?
    private let consumableType: String?
    
    private let name = "consumable_depleted"
    private let thingIDParamKey = "thing_id"
    private let consumableTypeParamKey = "consumable_type"
    
    public init(thingId: String?, consumableType: String?, screenName: String? = nil) {
        self.screenName = screenName
        self.thingId = thingId
        self.consumableType = consumableType
    }
    
    //MARK: AnalyticsEvent
    
    public var customParams: Dictionary<String, String> {
        
        var params = Dictionary<String, String>()
        
        if let screenName = screenName {
            params.updateValue(screenName, forKey: AnalyticsConstants.screenNameKey)
        }
        
        if let thingId = thingId {
            params.updateValue(thingId, forKey: thingIDParamKey)
        }
        
        if let consumableType = consumableType {
            params.updateValue(consumableType, forKey: consumableTypeParamKey)
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
        return [.All, .Engagement]
    }
}
