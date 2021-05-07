
//
//  Room.swift
//  Koleda
//
//  Created by Oanh tran on 7/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation


enum SettingType: String, Codable {
    case unknow
    case SMART = "SMART"
    case MANUAL = "MANUAL"
    case DEFAULT = "DEFAULT"
    case SCHEDULE = "SCHEDULE"
    init(fromString string: String) {
        guard let value = SettingType(rawValue: string) else {
            self = .unknow
            return
        }
        self = value
    }
}

enum SmartMode: String, Codable {
    case unknow
    case ECO = "ECO"
    case NIGHT = "NIGHT"
    case COMFORT = "COMFORT"
    case DEFAULT = "DEFAULT"
    case SMARTSCHEDULE = "SCHEDULE"
    init(fromString string: String) {
        guard let value = SmartMode(rawValue: string) else {
            self = .unknow
            return
        }
        self = value
    }
}

struct Room: Codable {
    let id: String
    var name: String
    var category: String
    var heaters: [Heater]?
    var sensor: Sensor?
    var battery: String?
    var originalTemperature: String?
    var enabled: Bool?
    var humidity: String?
    var setting: SettingItem?
    
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case category = "category"
        case heaters = "heaters"
        case sensor = "sensor"
        case battery = "battery"
        case originalTemperature = "temperature"
        case enabled = "enabled"
        case humidity = "humidity"
        case setting = "setting"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.category = try container.decode(String.self, forKey: .category)
        self.heaters = try container.decode([Heater].self, forKey: .heaters)
        self.sensor = try container.decodeIfPresent(Sensor.self, forKey: .sensor)
        self.battery = try container.decodeIfPresent(String.self, forKey: .battery)
        self.originalTemperature = try container.decodeIfPresent(String.self, forKey: .originalTemperature)
        self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled)
        self.humidity = try container.decodeIfPresent(String.self, forKey: .humidity)
        self.setting = try container.decodeIfPresent(SettingItem.self, forKey: .setting)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.heaters, forKey: .heaters)
        try container.encode(self.category, forKey: .category)
        try container.encode(self.battery, forKey: .battery)
        try container.encode(self.originalTemperature, forKey: .originalTemperature)
        try container.encode(self.enabled, forKey: .enabled)
        try container.encode(self.humidity, forKey: .humidity)
        try container.encode(self.setting, forKey: .setting)
    }
}
extension Room {
    var temperature: String? {
        if UserDataManager.shared.temperatureUnit == .C {
            guard let temp = originalTemperature, let celsiusTemperature = Double(temp) else {
                return originalTemperature
            }
            return "\(celsiusTemperature.roundToDecimal(1))"
        } else {
            return originalTemperature?.fahrenheitTemperature
        }
    }
}


struct Sensor: Codable {
    let id : String
    var deviceModel: String
    var name: String
    var enabled: Bool
    var ipAddress: String?
    
    init(deviceModel: String, name: String, ipAddress: String, enabled: Bool = true) {
        self.id = ""
        self.deviceModel = deviceModel
        self.name = name
        self.ipAddress = ipAddress
        self.enabled = enabled
    }
}

struct Heater: Codable {
    let id: String
    var deviceModel: String
    var name: String
    var enabled: Bool
    var ipAddress: String?
    
    init(deviceModel: String, name: String, enabled: Bool = false, ipAddress: String?) {
        self.id = ""
        self.name = name
        self.enabled = enabled
        self.deviceModel = deviceModel
        self.ipAddress = ipAddress
    }
}

struct SettingItem: Codable {
    let created: String
    let mode: String?
    let type: String?
    let data: DataConfiguration?
    let enableSchedule: Bool?
}

struct DataConfiguration: Codable {
    let time: Int?
    let temp: Double
}

extension DataConfiguration {
    var tempBaseOnUnit: Double {
        if UserDataManager.shared.temperatureUnit == .C {
            return temp
        } else {
            return temp.fahrenheitTemperature
        }
    }
}

extension Room {
    init(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        name = json["name"] as? String ?? ""
        category = json["category"] as? String ?? ""
        sensor = nil
        heaters = []
        battery = nil
        originalTemperature = nil
        enabled = nil
        humidity = nil
        setting = nil
    }
}
