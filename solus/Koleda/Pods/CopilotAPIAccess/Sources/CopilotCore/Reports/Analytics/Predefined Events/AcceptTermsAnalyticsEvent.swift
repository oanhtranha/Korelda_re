//
//  AcceptTermsAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct AcceptTermsAnalyticsEvent: AnalyticsEvent {
    
    let name = "accept_terms"
    let versionParamKey = "version"
    
    let version: String
    
    public init(version: String) {
        self.version = version
    }
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        return [versionParamKey : version, AnalyticsConstants.screenNameKey : eventName]
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
