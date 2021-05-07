//
//  RoomType.swift
//  Koleda
//
//  Created by Oanh tran on 7/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

enum RoomCategory: String, Codable {
    case unknow
    case living = "LIVING_ROOM"
    case bed = "BED_ROOM"
    case kid = "KID_ROOM"
    case kitchen = "KITCHEN"
    case music = "MUSIC_ROOM"
    case hallway = "HALLWAY"
    case reading = "READING_ROOM"
    case bathroom = "BATHROOM"
    case working = "WORKING_ROOM"
    
    init(fromString string: String) {
        guard let value = RoomCategory(rawValue: string) else {
            self = .unknow
            return
        }
        self = value
    }
}

struct RoomType {
    let category: RoomCategory
    let title: String
    let roomDetailImage: UIImage?
    let homeImage: UIImage?
    let configurationRoomImage: UIImage?
    
    init(category: RoomCategory, title: String, roomDetailImage: UIImage?, homeImage: UIImage?, configurationRoomImage: UIImage?) {
        self.category = category
        self.title = title
        self.roomDetailImage = roomDetailImage
        self.homeImage = homeImage
        self.configurationRoomImage = configurationRoomImage
    }
    
    static func initRoomTypes() -> [RoomType] {
        var roomTypes: [RoomType] = []
        roomTypes.append(RoomType(category: .living, title: "LIVING_ROOM_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_living"), homeImage: UIImage(named: "home_room_living"), configurationRoomImage: UIImage(named: "config_room_living")))
        roomTypes.append(RoomType(category: .music, title: "MUSIC_ROOM_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_music"), homeImage: UIImage(named: "home_room_music"), configurationRoomImage: UIImage(named: "config_room_music")))
        roomTypes.append(RoomType(category: .hallway, title: "HALLWAY_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_hallway"), homeImage: UIImage(named: "home_room_hallway"), configurationRoomImage: UIImage(named: "config_room_hallway")))
        roomTypes.append(RoomType(category: .reading, title: "READING_ROOM_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_reading"), homeImage: UIImage(named: "home_room_reading"), configurationRoomImage: UIImage(named: "config_room_reading")))
        roomTypes.append(RoomType(category: .bed, title: "BED_ROOM_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_bed"), homeImage: UIImage(named: "home_room_bed"), configurationRoomImage: UIImage(named: "config_room_bed")))
        roomTypes.append(RoomType(category: .kid, title: "KIDS_ROOM_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_kid"), homeImage: UIImage(named: "home_room_kid"), configurationRoomImage: UIImage(named: "config_room_kid")))
        roomTypes.append(RoomType(category: .bathroom, title: "BATHROOM_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_bathroom"), homeImage: UIImage(named: "home_room_bathroom"), configurationRoomImage: UIImage(named: "config_room_bathroom")))
        roomTypes.append(RoomType(category: .working, title: "WORKING_ROOM_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_working"), homeImage: UIImage(named: "home_room_working"), configurationRoomImage: UIImage(named: "config_room_working")))
        roomTypes.append(RoomType(category: .kitchen, title: "KITCHEN_TEXT".app_localized, roomDetailImage: UIImage(named: "detail_room_kitchen"), homeImage: UIImage(named: "home_room_kitchen"), configurationRoomImage: UIImage(named: "config_room_kitchen")))
        return roomTypes
    }
    
    static func roomDetailImageOf(category: RoomCategory) -> UIImage? {
        let roomType = initRoomTypes().filter { $0.category == category}.first
        return roomType?.roomDetailImage
    }
    
    static func homeImageOf(category: RoomCategory) -> UIImage? {
        let roomType = initRoomTypes().filter { $0.category == category}.first
        return roomType?.homeImage
    }
    
    static func configrurationRoomImageOf(category: RoomCategory) -> UIImage? {
        let roomType = initRoomTypes().filter { $0.category == category}.first
        return roomType?.configurationRoomImage
    }
}

extension RoomType {
    static func == (lhs: RoomType, rhs: RoomType) -> Bool {
        return lhs.category == rhs.category
    }
}
