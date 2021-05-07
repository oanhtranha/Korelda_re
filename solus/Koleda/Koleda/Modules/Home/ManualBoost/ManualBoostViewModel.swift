

//
//  ManualBoostViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 8/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol  ManualBoostViewModelProtocol: BaseViewModelProtocol {
    var currentTemperature: Variable<String> { get }
    var editingTemprature: Variable<Int> { get }
    var editingTempratureSmall: Variable<Int> { get }
    var statusString: Variable<String> { get }
    var sliderValue: Variable<Float> { get }
    var endTime: Variable<String> { get }
    var countDownTime: Variable<String> { get }
    var manualBoostTimeout: PublishSubject<Void> { get }
    
    
    func adjustTemprature(increased: Bool)
    func resetSettingTime(completion: @escaping (Bool, String) -> Void)
    func updateSettingTime(seconds: Int)
    func manualBoostUpdate(completion: @escaping (Bool) -> Void)
    func needUpdateSelectedRoom()
    func setup()
    func refreshRoom(completion: @escaping (Bool) -> Void)
}

class ManualBoostViewModel: BaseViewModel, ManualBoostViewModelProtocol {
    
    let currentTemperature = Variable<String>("")
    let editingTemprature = Variable<Int>(0)
    let editingTempratureSmall = Variable<Int>(0)
    let statusString =  Variable<String>("")
    let sliderValue = Variable<Float>(0)
    let endTime = Variable<String>("")
    let countDownTime = Variable<String>("")
    let manualBoostTimeout = PublishSubject<Void>()
    
    let router: BaseRouterProtocol
    private let roomManager: RoomManager
    private let settingManager: SettingManager
    private var seletedRoom: Room?
    private var timer:Timer?
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, seletedRoom: Room? = nil) {
        self.router = router
        self.roomManager = managerProvider.roomManager
        self.settingManager = managerProvider.settingManager
        self.seletedRoom = seletedRoom
        super.init(managerProvider: managerProvider)
    }
    
    func setup() {
        guard let userName = UserDataManager.shared.currentUser?.name, let room = seletedRoom else {
            return
        }
        let roomViewModel = RoomViewModel.init(room: room)
        currentTemperature.value = roomViewModel.temprature
        editingTemprature.value = roomViewModel.settingTemprature.0
        editingTempratureSmall.value = roomViewModel.settingTemprature.1
        countDownTime.value = roomViewModel.remainSettingTime.fullTimeFormart()
        updateSettingTime(seconds: roomViewModel.endTimePoint)
        guard let sensor = roomViewModel.sensor else {
            return
        }
        updateStatusOfTemperature()
    }
    
    func adjustTemprature(increased: Bool) {
        if increased {
           increaseTemp()
        } else {
           decreaseTemp()
        }
        updateStatusOfTemperature()
    }
    
    func updateSettingTime(seconds: Int) {
        
        sliderValue.value = Float(seconds)
        guard seconds <= Constants.MAX_END_TIME_POINT else {
            endTime.value = "UNLIMITED_TEXT"
            countDownTime.value = ""
            stopTimer()
            return
        }
        if seconds == 0 {
            endTime.value = "00:00"
            countDownTime.value = seconds.fullTimeFormart()
            stopTimer()
        } else {
            let time = Date().adding(seconds: seconds)
            endTime.value = String(format: "%@ %@", "UNTIL_TEXT".app_localized,time.fomartAMOrPm())
            countDownTime.value = seconds.fullTimeFormart()
            runTimer()
        }
    }
    
    func resetSettingTime(completion: @escaping (Bool, String) -> Void) {
        if let room = seletedRoom {
            let roomViewModel = RoomViewModel.init(room: room)
            if roomViewModel.settingType == .MANUAL {
                settingManager.resetManualBoost(roomId: room.id, success: { [weak self] in
                    completion(true, "")
                }) { _ in
                    completion(false, "MANUAL_BOOST_CAN_NOT_RESET_MESS".app_localized)
                }
            } else {
                 setup()
                 completion(false, "")
            }
        }
    }
    
    func needUpdateSelectedRoom() {
        let room = UserDataManager.shared.rooms.filter { $0.id == seletedRoom?.id }.first
        if room != nil {
            seletedRoom = room
            setup()
        }
    }
    
    func manualBoostUpdate(completion: @escaping (Bool) -> Void) {
        guard let roomId = seletedRoom?.id else {
            completion(false)
            return
        }
        let time = Int(sliderValue.value)
        var temprature: Double = Double(editingTemprature.value) + Double(editingTempratureSmall.value) * 0.1
        if UserDataManager.shared.temperatureUnit == .F {
            temprature = temprature.celciusTemperature
        }
        roomManager.manualBoostUpdate(roomId: roomId, temp: temprature, time: time > Constants.MAX_END_TIME_POINT ? 0 : time, success: {
            completion(true)
        }, failure: { error in
            completion(false)
        })
    }
    
    func refreshRoom(completion: @escaping (Bool) -> Void) {
        guard let roomId = seletedRoom?.id else {
            completion(false)
            return
        }
        roomManager.getRoom(roomId: roomId, success: { [weak self] room in
            self?.seletedRoom = room
            self?.setup()
            completion(true)
            }, failure: { error in
                completion(false)
        })
    }
    
    private func increaseTemp() {
        let maxTemp = UserDataManager.shared.temperatureUnit == .C ? Constants.MAX_TEMPERATURE : Constants.MAX_TEMPERATURE.fahrenheitTemperature
        guard editingTemprature.value < Int(maxTemp) else {
            return
        }
        if UserDataManager.shared.temperatureUnit == .C {
            if editingTempratureSmall.value == 0 {
                editingTempratureSmall.value = 5
            } else {
                editingTempratureSmall.value = 0
                editingTemprature.value = editingTemprature.value + 1
                
            }
        } else {
            editingTemprature.value = editingTemprature.value + 1
        }
        
    }
    
    private func decreaseTemp() {
        if UserDataManager.shared.temperatureUnit == .C {
            guard editingTemprature.value > 5 || (editingTemprature.value == 5 && editingTempratureSmall.value > 0) else {
                return
            }
            if editingTempratureSmall.value == 0 {
                editingTempratureSmall.value = 5
                editingTemprature.value = editingTemprature.value - 1
            } else {
                editingTempratureSmall.value = 0
            }
        } else {
            guard editingTemprature.value > 0 else {
                return
            }
            editingTemprature.value = editingTemprature.value - 1
        }
    }
    
    private func updateStatusOfTemperature() {
        let currentTemp = currentTemperature.value.kld_doubleValue ?? 0
        let targetTemp: Double = Double(editingTemprature.value) + Double(editingTempratureSmall.value) * 0.1
        if targetTemp != 0 && currentTemp != 0 && targetTemp != currentTemp {
            statusString.value = targetTemp > currentTemp ? "HEATING_TO_TEXT".app_localized : "COOLING_DOWN_TEXT".app_localized
        } else {
            statusString.value = ""        }
    }
    
    private func runTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountDown), userInfo: nil, repeats: true )
    }
    
    private func stopTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @objc private func updateCountDown() {
        if(sliderValue.value > 0) {
            sliderValue.value = sliderValue.value -  1
            countDownTime.value = Int(sliderValue.value).fullTimeFormart()
            log.info(countDownTime.value)
        } else {
            manualBoostTimeout.onNext(())
            stopTimer()
        }
    }
}
