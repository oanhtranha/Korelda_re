//
//  ThingConnectionFailedAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct ThingConnectionFailedAnalyticsEvent: AnalyticsEvent {
    
    let name = "thing_connection_failed"
    let failureReasonParamKey = "failure_reason"
    
    var failureReason: String
    
    public init(failureReason: String) {
        self.failureReason = failureReason
    }
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        return [failureReasonParamKey : failureReason]
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All, .Engagement]
    }
}
