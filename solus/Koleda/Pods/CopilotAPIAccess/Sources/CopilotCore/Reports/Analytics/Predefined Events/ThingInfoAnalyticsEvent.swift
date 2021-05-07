//
//  ThingInfoAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 04/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct ThingInfoAnalyticsEvent: AnalyticsEvent {
    
    let name = "thing_info"
    let thingFirmwareParamKey = "thing_firmware"
    let thingModelParamKey = "thing_model"
    let thingIdParamKey = "thing_id"
    
    let thingFirmware: String
    let thingModel: String
    let thingId: String
    
    public init(thingFirmware: String, thingModel: String, thingId: String) {
        self.thingFirmware = thingFirmware
        self.thingModel = thingModel
        self.thingId = thingId
    }
    
    //MARK: AnalyticsEvent
    
    public var customParams: Dictionary<String, String> {
        return [thingFirmwareParamKey : thingFirmware, thingModelParamKey : thingModel, thingIdParamKey: thingId]
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .Thing
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All, .Engagement, .Main]
    }
}
