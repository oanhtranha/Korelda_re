//
//  ModeAnalyticsEvent.swift
//  Koleda
//
//  Created by Oanh Tran on 9/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import CopilotAPIAccess

struct UpdateManualBoostAnalyticsEvent: AnalyticsEvent {
    
    private let roomId: String
    private let temp: Double
    private let time: Int
    private let screenName: String

    init(roomId:String, temp: Double, time: Int, screenName: String) {
        self.roomId = roomId
        self.temp = temp
        self.time = time
        self.screenName = screenName
    }

    var customParams: Dictionary<String, String> {
        return ["roomId" : roomId,
                "temp" : String(temp),
                "time" : String(time),
                "screenName": screenName]
    }

    var eventName: String {
        return "update_manual_boost"
    }

    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }

    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct ResetManualBoostAnalyticsEvent: AnalyticsEvent {
    
    private let roomId: String
    private let screenName: String
    
    init(roomId:String, screenName: String) {
        self.roomId = roomId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["roomId" : roomId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "reset_manual_boost"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct SetModeAnalyticsEvent: AnalyticsEvent {
    
    private let roomId: String
    private let mode: String
    private let screenName: String
    
    init(roomId:String, mode: String, screenName: String) {
        self.roomId = roomId
        self.mode = mode
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["roomId" : roomId,
                "mode" : mode,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "set_mode"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct SetSmartScheduleAnalyticsEvent: AnalyticsEvent {
    
    private let schedules: ScheduleOfDay
    private let screenName: String
    
    init(schedules: ScheduleOfDay, screenName: String) {
        self.schedules = schedules
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["schedules" : schedules.convertToDictionary().description,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "set_smart_schedule"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

