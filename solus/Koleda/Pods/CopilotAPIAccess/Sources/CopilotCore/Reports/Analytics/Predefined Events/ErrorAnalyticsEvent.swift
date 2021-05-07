//
//  ErrorAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct ErrorAnalyticsEvent: AnalyticsEvent {
    
    let name = "error_report"
    let errorTypeParamKey = "error_type"
    
    let errorType: String
    var screenName: String?
    
    public init (errorType: String, screenName: String? = nil) {
        self.errorType = errorType
        self.screenName = screenName
    }
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        var params = [errorTypeParamKey : errorType]
        
        if let screenName = screenName {
            params.updateValue(screenName, forKey: AnalyticsConstants.screenNameKey)
        }
        
        return params
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .Server
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
