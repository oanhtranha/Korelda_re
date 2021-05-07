//
//  FirmwareUpgradeCompletedAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct FirmwareUpgradeCompletedAnalyticsEvent: AnalyticsEvent {
    
    let name = "firmware_upgrade_complete"
    let statusParamKey = "status"
    
    let fwUpgradeStatus: FirmwareUpgradeStatus
    
    public enum FirmwareUpgradeStatus: String {
        case Success
        case Failure
    }
    
    public init (firmwareUpgradeStatus: FirmwareUpgradeStatus) {
        fwUpgradeStatus = firmwareUpgradeStatus
    }
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        return [statusParamKey : fwUpgradeStatus.rawValue]
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All, .Engagement, .Main, .DevSupport]
    }
}

