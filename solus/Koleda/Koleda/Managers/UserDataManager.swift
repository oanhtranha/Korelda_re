
//
//  UserDataManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/15/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

enum TemperatureUnit: String{
    case F = "F"
    case C = "C"
    case unknow
    
    init(fromString string: String) {
        guard let value = TemperatureUnit(rawValue: string) else {
            self = .unknow
            return
        }
        self = value
    }
}

struct StepProgressBar {
	let totalStep: Int
	var currentStep: Int
	
	init(total: Int = 0, step: Int = 0) {
		self.totalStep = total
		self.currentStep = step
	}
}


final class UserDataManager {
    static let shared = UserDataManager()
    var currentUser: User?
    var tariff: Tariff?
    var wifiInfo: WifiInfo?
    
    var rooms : [Room]
    var deviceModelList: [String]
    var temperatureUnit: TemperatureUnit
    var energyConsumed: ConsumeEneryTariff?
    var settingModes: [ModeItem]
    var smartScheduleData: [String:ScheduleOfDay]
	var stepProgressBar = StepProgressBar()
    var friendsList: [String]
    
    
    private init() {
        rooms = []
        deviceModelList = []
        temperatureUnit = .C
        energyConsumed = nil
        smartScheduleData = [:]
        settingModes = []
		stepProgressBar = StepProgressBar()
        friendsList = []
    }
    
    func clearUserData() {
        rooms = []
		deviceModelList = []
		temperatureUnit = .C
		energyConsumed = nil
		smartScheduleData = [:]
		settingModes = []
		stepProgressBar = StepProgressBar()
        friendsList = []
		
        currentUser = nil
        tariff =  nil
        wifiInfo = nil
    }
    
    func roomWith(roomId: String) -> Room? {
        return rooms.first(where: { $0.id == roomId })
    }
    
    func settingModesWithoutDefaultMode() -> [ModeItem] {
        return settingModes.filter { $0.mode != .DEFAULT}
    }
}
