//
//  RoomViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 9/6/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

class RoomViewModel {
    let isLowBattery: Bool
    let roomName: String
    let onOffSwitchStatus: Bool
    let temprature: String
    let infoMessage: String
    let roomHomeImage: UIImage?
    let roomConfigurationImage: UIImage?
    let humidity: String
    let sensorBattery: String
    let sensor: Sensor?
    let settingType: SettingType
    let smartMode: SmartMode
    let heaters: [Heater]?
    let settingTemprature: (Int,Int)
    let remainSettingTime: Int
    let endTimePoint: Int
    var currentTemp: Double? = nil
    var enableSchedule: Bool = false
    
    private (set) var room: Room
    
    init(room: Room) {
        self.room = room
        roomName =  room.name
        onOffSwitchStatus = room.enabled ?? false
        roomHomeImage = RoomType.homeImageOf(category: RoomCategory(fromString: room.category))
        roomConfigurationImage = RoomType.configrurationRoomImageOf(category: RoomCategory(fromString: room.category))
        
        if let battery = room.battery?.kld_doubleValue {
            isLowBattery = battery <= 10
            sensorBattery = "\(battery)"
        } else {
            sensorBattery = "-"
            isLowBattery = false
        }
        
        if let temp = room.temperature {
            temprature = "\(temp)"
            currentTemp = Double(temp)
        } else {
            temprature = "-"
            currentTemp = nil
        }
        
        if let humi = room.humidity {
            humidity = "\(humi)"
        } else {
            humidity = "-"
        }
        
        if let sensor = room.sensor {
            self.sensor = sensor
        } else {
            self.sensor = nil
        }
        
        if let heaters = room.heaters  {
            self.heaters = heaters
        } else {
            self.heaters = nil
        }
        guard let setting = room.setting, let type = setting.type, let data = setting.data else {
            settingType = .unknow
            smartMode = .unknow
            endTimePoint = 0
            remainSettingTime = 0
            infoMessage = ""
            settingTemprature = (0,0)
            return
        }
        enableSchedule = setting.enableSchedule ?? false
        settingType = SettingType.init(fromString: type)
        if let mode = setting.mode {
            smartMode = SmartMode.init(fromString: mode)
        } else {
            smartMode = .unknow
        }
        
        let temp = data.tempBaseOnUnit
        settingTemprature = (temp.integerPart(),temp.fractionalPart())
       
        guard onOffSwitchStatus else {
            endTimePoint = 0
            remainSettingTime = 0
            infoMessage = "TURNED_OFF_VIA_SCHEDULE".app_localized
            return
        }
        
        if settingType == .MANUAL, let time =  data.time {
            endTimePoint = time == 0 ?  Constants.MAX_END_TIME_POINT + 1 : time // if time == 0 mean MANUAL BOOST is Unlimit
            remainSettingTime = time
            let targetTempString = "TARGET_TEMPERATURE".app_localized
            infoMessage = "\(targetTempString): <h1>\(temp)</h1>"
        } else {
            endTimePoint = 0
            remainSettingTime = 0
            let modeString = "MODE_TEXT".app_localized
            infoMessage = "\(smartMode.rawValue.capitalizingFirstLetter()) \(modeString): <h1>\(temp)</h1>"
        }
    }
}
