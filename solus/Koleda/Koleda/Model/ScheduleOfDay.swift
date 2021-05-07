//
//  ScheduleOfDay.swift
//  Koleda
//
//  Created by Oanh tran on 10/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

struct ScheduleOfDay: Codable {
    let id: String?
    let userId: String
    let dayOfWeek: String
    let details: [ScheduleOfTime]
    
    func convertToDictionary() -> Dictionary<String, Any> {
        var detailSchedules: [Dictionary<String, Any>] = []
        for detail in self.details {
            let scheduleDic: Dictionary<String, Any> = ["from": detail.from, "to": detail.to.correctLocalTimeStringFormatForService, "mode": detail.mode, "roomIds": detail.roomIds]
            detailSchedules.append(scheduleDic)
        }
        return [
            "dayOfWeek": self.dayOfWeek,
            "details": detailSchedules
        ]
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case userId = "userId"
        case dayOfWeek = "dayOfWeek"
        case details = "details"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.dayOfWeek = try container.decode(String.self, forKey: .dayOfWeek)
        self.details = try container.decode([ScheduleOfTime].self, forKey: .details)
    }
}

struct ScheduleOfTime: Codable {
    let from: String
    let to: String
    let mode: String
    let roomIds: [String]
    
    init(from: String, to: String, mode: String, roomIds: [String]) {
        self.from = from
        self.to = to
        self.mode = mode
        self.roomIds = roomIds
    }
}

extension ScheduleOfTime {
    var rooms: [Room] {
        var matchRooms: [Room] = []
        for roomId in roomIds {
            if let room = UserDataManager.shared.roomWith(roomId: roomId) {
                matchRooms.append(room)
            }
        }
        return matchRooms
    }
}

extension ScheduleOfDay {
    init(dayOfWeek: String, details: [ScheduleOfTime]) {
        self.dayOfWeek = dayOfWeek
        self.details = details
        id = ""
        userId = ""
    }
}
