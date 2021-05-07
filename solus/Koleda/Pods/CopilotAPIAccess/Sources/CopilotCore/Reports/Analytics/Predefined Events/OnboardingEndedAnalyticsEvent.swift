//
//  OnboardingEndedAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct OnboardingEndedAnalyticsEvent: AnalyticsEvent {
    
    let name = "onboarding_ended"
    let flowIDParamKey = "flow_id"
    
    var screenName: String?
    var flowID: String?
    
    public init(flowID: String? = nil, screenName: String? = nil) {
        self.screenName = screenName
        self.flowID = flowID
    }
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        var params = Dictionary<String, String>()
        
        if let flowID = self.flowID {
            params.updateValue(flowID, forKey: flowIDParamKey)
        }
        if let screenName = self.screenName {
            params.updateValue(screenName, forKey: AnalyticsConstants.screenNameKey)
        }
        
        return params
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
