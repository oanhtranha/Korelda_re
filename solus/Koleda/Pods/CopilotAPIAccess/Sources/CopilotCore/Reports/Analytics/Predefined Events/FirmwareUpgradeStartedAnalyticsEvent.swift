//
//  FirmwareUpgradeStartedAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct FirmwareUpgradeStartedAnalyticsEvent: AnalyticsEvent {
    
    let name = "firmware_upgrade_started"
    
    public init() {}
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        return Dictionary<String, String>()
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    public var eventGroups:[AnalyticsEventGroup] {
        return [.All, .Engagement, .Main, .DevSupport]
    }
}
