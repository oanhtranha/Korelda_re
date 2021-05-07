//
//  TapConnectDeviceAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct TapConnectDeviceAnalyticsEvent: AnalyticsEvent {
    
    let name = "tap_connect_device"
    
    public init() {}
    
    //MARK: AnalyticsEvent
    
    public var customParams: Dictionary<String, String> {
        return Dictionary<String, String>()
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
