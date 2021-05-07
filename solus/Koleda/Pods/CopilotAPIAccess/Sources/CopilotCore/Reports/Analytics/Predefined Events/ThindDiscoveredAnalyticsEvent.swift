//
//  ThindDiscoveredAnalyticsEvent.swift
//
//
//  Created by Michael Noy on 06/02/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct ThingDiscoveredAnalyticsEvent: AnalyticsEvent {
    
    private let name = "thing_discovered"
    private let thingIDParamKey = "thing_id"
    
    private var thingID: String?
    
    public init(thingID: String? = nil) {
        self.thingID = thingID
    }
    
    //MARK: AnalyticsEvent
    
    public var customParams: Dictionary<String, String> {
        var params = [String: String]()
        
        if let thingID = thingID {
            params.updateValue(thingID, forKey: thingIDParamKey)
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
