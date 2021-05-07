//
//  RoomAnalyticsEvent.swift
//  Koleda
//
//  Created by Oanh Tran on 9/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import CopilotAPIAccess

struct AddRoomAnalyticsEvent: AnalyticsEvent {
    
    private let roomName: String
    private let homeId: String
    private let screenName: String
    
    init(roomName:String,homeId: String, screenName: String) {
        self.roomName = roomName
        self.homeId = homeId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["roomName" : roomName,
                "homeId" : homeId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "add_room"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct editRoomAnalyticsEvent: AnalyticsEvent {
    
    private let roomId: String
    private let roomName: String
    private let homeId: String
    private let screenName: String
    
    init(roomId: String, roomName: String, homeId: String, screenName: String) {
        self.roomId = roomId
        self.roomName = roomName
        self.homeId = homeId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["roomId" : roomId,
                "roomName" : roomName,
                "homeId" : homeId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "edit_room"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct removeRoomAnalyticsEvent: AnalyticsEvent {
    
    private let roomId: String
    private let roomName: String
    private let homeId: String
    private let screenName: String
    
    init(roomId: String, roomName: String, homeId: String, screenName: String) {
        self.roomId = roomId
        self.roomName = roomName
        self.homeId = homeId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["roomId" : roomId,
                "roomName" : roomName,
                "homeId" : homeId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "remove_room"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct UpdateRoomStatusAnalyticsEvent: AnalyticsEvent {
    
    private let homeId: String
    private let roomId: String
    private let isEnable: Bool
    private let screenName: String
    
    init(homeId: String, roomId: String, isEnable: Bool, screenName: String) {
        self.roomId = roomId
        self.homeId = homeId
        self.isEnable = isEnable
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["roomId" : roomId,
                "homeId" : homeId,
                "isEnable" : String(isEnable),
                "screenName": screenName]
    }
    
    var eventName: String {
        if isEnable {
            return "turn_on_room"
        } else {
            return "turn_off_room"
        }
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}


