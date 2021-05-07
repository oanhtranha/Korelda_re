//
//  ContactSupportAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 13/06/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct ContactSupportAnalyticsEvent: AnalyticsEvent {
    
    private let screenName: String?
    private let thingId: String?
    private let supportCase: String?
    
    private let name = "contact_support"
    private let thingIDParamKey = "thing_id"
    private let supportCaseParamKey = "support_case"
    
    public init(supportCase: String?, thingId: String?, screenName: String? = nil) {
        self.screenName = screenName
        self.thingId = thingId
        self.supportCase = supportCase
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
        
        if let supportCase = supportCase {
            params.updateValue(supportCase, forKey: supportCaseParamKey)
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
