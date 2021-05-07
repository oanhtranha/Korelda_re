
//
//  SensorAnalyticsEvent.swift
//  Koleda
//
//  Created by Oanh Tran on 9/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import CopilotAPIAccess

struct AddSensorAnalyticsEvent: AnalyticsEvent {
    
    private let sensorModel: String
    private let roomId: String
    private let homeId: String
    private let screenName: String
    
    init(sensorModel:String, roomId: String, homeId: String, screenName: String) {
        self.sensorModel = sensorModel
        self.roomId = roomId
        self.homeId = homeId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["sensorModel" : sensorModel,
                "roomId" : roomId,
                "homeId" : homeId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "add_sensor"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct RemoveSensorAnalyticsEvent: AnalyticsEvent {
    
    private let sensorId: String
    private let screenName: String
    
    init(sensorId:String, screenName: String) {
        self.sensorId = sensorId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["sensorId" : sensorId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "remove_sensor"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}



