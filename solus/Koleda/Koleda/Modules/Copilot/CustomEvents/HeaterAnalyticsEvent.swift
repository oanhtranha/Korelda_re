//
//  HeaterAnalyticsEvent.swift
//  Koleda
//
//  Created by Oanh Tran on 9/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import CopilotAPIAccess

struct AddHeaterAnalyticsEvent: AnalyticsEvent {
    
    private let heaterModel: String
    private let roomId: String
    private let homeId: String
    private let screenName: String
    
    init(heaterModel:String, roomId: String, homeId: String, screenName: String) {
        self.heaterModel = heaterModel
        self.roomId = roomId
        self.homeId = homeId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["heaterModel" : heaterModel,
                "roomId" : roomId,
                "homeId" : homeId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "add_heater"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}

struct RemoveHeaterAnalyticsEvent: AnalyticsEvent {
    
    private let heaterId: String
    private let screenName: String
    
    init(heaterId:String, screenName: String) {
        self.heaterId = heaterId
        self.screenName = screenName
    }
    
    var customParams: Dictionary<String, String> {
        return ["heaterId" : heaterId,
                "screenName": screenName]
    }
    
    var eventName: String {
        return "remove_heater"
    }
    
    var eventOrigin: AnalyticsEventOrigin {
        return .App
    }
    
    var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}



