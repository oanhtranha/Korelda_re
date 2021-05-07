//
//  SelectedRoomViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 8/26/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import CopilotAPIAccess

protocol SelectedRoomViewModelProtocol: BaseViewModelProtocol {
    var homeTitle: Variable<String> { get }
    var temperature: Variable<String> { get }
    var humidity: Variable<String> { get }
    var sensorBattery: Variable<String> { get }
	var turnOnRoom: PublishSubject<Bool> { get }
	
	var modeItems: Variable<[ModeItem]> { get }
	var ecoModeUpdate: PublishSubject<Bool> { get }
	var comfortModeUpdate: PublishSubject<Bool> { get }
	var nightModeUpdate: PublishSubject<Bool> { get }
	var smartScheduleModeUpdate: PublishSubject<Bool> { get }
	
    var canAdjustTemp: PublishSubject<Bool> { get }
  //update
	var currentValueSlider: Int { get }
	var editingTemprature: Variable<Int> { get }
	var editingTempratureSmall: Variable<Int> { get }
	var statusText: Variable<String> { get }
	var statusImageName: Variable<String> { get }
	var startTemprature: Variable<Int> { get }
	var endTemprature: Variable<Int> { get }
	var timeSliderValue: Variable<Float> { get }
	var endTime: Variable<String> { get }
	var countDownTime: Variable<String> { get }
    var turnOnManualBoost: Variable<Bool> { get }
    var temperatureSliderRange: [Int] { get }
    var refreshTempCircleSlider: PublishSubject<Void> { get }
    var performBoosting: PublishSubject<Void> { get }
    var manualBoostTimeout: PublishSubject<Void> { get }
    
    var settingType: SettingType { get }
    var heaters: [Heater] { get }


    func setup()
    func showConfigurationScreen()
    func needUpdateSelectedRoom()
    func updateSettingMode(mode: SmartMode, completion: @escaping (SmartMode, Bool, String) -> Void)
    func changeSmartMode(seletedSmartMode: SmartMode)
    func turnOnOrOffRoom(completion: @escaping (_ isTurnOn: Bool, _ isSuccess: Bool) -> Void)
    func turnOnOrOffScheduleMode(completion: @escaping (Bool, String) -> Void)
	
	//update
	func updateSettingTime(seconds: Int)
	func adjustTemprature(increased: Bool)
	func temperatureSliderChanged(value: Int)
    func manualBoostUpdate(completion: @escaping (Bool) -> Void)
    func resetManualBoost(completion: @escaping (Bool, String) -> Void)
	func refreshRoom(completion: @escaping (Bool) -> Void)
    func checkForAutoUpdateManualBoost(updatedTemp: Bool)
}

class SelectedRoomViewModel: BaseViewModel, SelectedRoomViewModelProtocol {
    
    let homeTitle = Variable<String>("")
    let temperature = Variable<String>("")
    let humidity = Variable<String>("")
    let sensorBattery = Variable<String>("")
	let turnOnRoom = PublishSubject<Bool>()
   
	var modeItems = Variable<[ModeItem]>([])
	var ecoModeUpdate = PublishSubject<Bool>()
	var comfortModeUpdate = PublishSubject<Bool>()
	var nightModeUpdate = PublishSubject<Bool>()
	var smartScheduleModeUpdate = PublishSubject<Bool>()
	
    let canAdjustTemp = PublishSubject<Bool>()
	
    var currentValueSlider = 0
    let editingTemprature = Variable<Int>(0)
    let editingTempratureSmall = Variable<Int>(0)
    var statusText = Variable<String>("")
    var statusImageName =  Variable<String>("")
    let startTemprature = Variable<Int>(0)
    let endTemprature = Variable<Int>(0)
    let timeSliderValue = Variable<Float>(0)
    let endTime = Variable<String>("")
    let countDownTime = Variable<String>("")
    let turnOnManualBoost = Variable<Bool>(false)
    var temperatureSliderRange: [Int] = []
    let refreshTempCircleSlider = PublishSubject<Void>()
    let performBoosting = PublishSubject<Void>()
    let manualBoostTimeout = PublishSubject<Void>()
    
    let router: BaseRouterProtocol
    private let roomManager: RoomManager
    private var seletedRoom: Room?
    private let schedulesManager: SchedulesManager
    private let settingManager: SettingManager
    private var currentSelectedMode: SmartMode = .DEFAULT
    
	var settingType: SettingType = .unknow
    var heaters: [Heater] = []
    var exitingSmartSchedule: Bool?
    var enableSchedule: Bool = false
    private var timer:Timer?
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, seletedRoom: Room? = nil) {
        self.router = router
        roomManager = managerProvider.roomManager
        schedulesManager =  managerProvider.schedulesManager
        settingManager =  managerProvider.settingManager
        self.seletedRoom = seletedRoom
        super.init(managerProvider: managerProvider)
    }
    
    func setup() {
        guard let userName = UserDataManager.shared.currentUser?.name, let room = seletedRoom else {
            return
        }
        
        let roomViewModel = RoomViewModel.init(room: room)
        turnOnRoom.onNext(roomViewModel.onOffSwitchStatus)
        homeTitle.value = roomViewModel.roomName
        temperature.value = roomViewModel.temprature
        humidity.value =  roomViewModel.humidity
        sensorBattery.value = roomViewModel.sensorBattery
        settingType = roomViewModel.settingType
        heaters = roomViewModel.heaters ?? []
        enableSchedule = roomViewModel.enableSchedule
        if let heater = roomViewModel.heaters, heater.count > 0 {
            canAdjustTemp.onNext(true)
        } else {
            canAdjustTemp.onNext(false)
        }
        modeItems.value = UserDataManager.shared.settingModes
        getExistingSmartSchedule()
        turnOnManualBoost.value = false
        switch settingType {
        case .MANUAL:
            changeSmartMode(seletedSmartMode: .DEFAULT)
            turnOnManualBoost.value = true
        case .SMART:
            changeSmartMode(seletedSmartMode: roomViewModel.smartMode)
        default:
            if enableSchedule {
                changeSmartMode(seletedSmartMode: .SMARTSCHEDULE)
            } else {
                changeSmartMode(seletedSmartMode: .DEFAULT)
            }
        }
        countDownTime.value = roomViewModel.remainSettingTime.fullTimeFormart()
        updateSettingTime(seconds: roomViewModel.endTimePoint)
        loadCurrentSliderTemperature(temp: roomViewModel.settingTemprature.0)
    }
    
    func turnOnOrOffRoom(completion: @escaping (_ isTurnOn: Bool, _ isSuccess: Bool) -> Void) {
        guard let room = seletedRoom else {
            completion(false, false)
            return
        }
        let roomViewModel = RoomViewModel.init(room: room)
        let status = !roomViewModel.onOffSwitchStatus
        roomManager.switchRoom(roomId: room.id, turnOn: status, success: {
            NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
            Copilot.instance.report.log(event: UpdateRoomStatusAnalyticsEvent(homeId: UserDataManager.shared.currentUser?.homes[0].id ?? "", roomId: room.id, isEnable:status, screenName: self.screenName))
            completion(status, true)
        }, failure: { _ in
            completion(status, false)
        })
    }
    
    func showConfigurationScreen() {
        guard let room = seletedRoom else {
            return
        }
        self.router.enqueueRoute(with: SelectedRoomRouter.RouteType.configuration(room))
    }
    
    func needUpdateSelectedRoom() {
        let room = UserDataManager.shared.rooms.filter { $0.id == seletedRoom?.id }.first
        if room != nil {
            seletedRoom = room
            setup()
        }
    }
    
    func changeSmartMode(seletedSmartMode: SmartMode) {
        currentSelectedMode = seletedSmartMode
        switch seletedSmartMode {
        case .ECO:
            ecoModeUpdate.onNext(true)
            comfortModeUpdate.onNext(false)
            nightModeUpdate.onNext(false)
            smartScheduleModeUpdate.onNext(false)
        case .COMFORT:
            ecoModeUpdate.onNext(false)
            comfortModeUpdate.onNext(true)
            nightModeUpdate.onNext(false)
            smartScheduleModeUpdate.onNext(false)
        case .NIGHT:
            ecoModeUpdate.onNext(false)
            comfortModeUpdate.onNext(false)
            nightModeUpdate.onNext(true)
            smartScheduleModeUpdate.onNext(false)
        case .SMARTSCHEDULE:
            ecoModeUpdate.onNext(false)
            comfortModeUpdate.onNext(false)
            nightModeUpdate.onNext(false)
            smartScheduleModeUpdate.onNext(true)
        default:
            ecoModeUpdate.onNext(false)
            comfortModeUpdate.onNext(false)
            nightModeUpdate.onNext(false)
            smartScheduleModeUpdate.onNext(false)
        }
    }
    
    func updateSettingMode(mode: SmartMode, completion: @escaping (SmartMode, Bool, String) -> Void) {
        let modeForUpdate = (mode == currentSelectedMode) ? .DEFAULT : mode
        callServiceToUpdateMode(mode: modeForUpdate) { isSuccess in
            if isSuccess {
                completion(modeForUpdate ,true, "")
            } else {
                completion(modeForUpdate ,false, "CAN_NOT_UPDATE_SETTING_MODE".app_localized)
            }
        }
    }
    //update
    func updateSettingTime(seconds: Int) {
        timeSliderValue.value = Float(seconds)
        guard seconds <= Constants.MAX_END_TIME_POINT else {
            endTime.value = ""
            countDownTime.value = "BOOSTING_UNTIL_YOU_CANCEL".app_localized
            stopTimer()
            return
        }
        if seconds == 0 {
            endTime.value = "00:00"
            countDownTime.value = seconds.fullTimeFormart()
            stopTimer()
        } else {
            let time = Date().adding(seconds: seconds)
            endTime.value = String(format: "BOOSTING_UNTIL_TIME".app_localized, time.fomartAMOrPm())
            countDownTime.value = seconds.fullTimeFormart()
            runTimer()
        }
    }
	
	func adjustTemprature(increased: Bool) {
		if increased {
			increaseTemp()
		} else {
			decreaseTemp()
		}
		loadCurrentSliderTemperature(temp: editingTemprature.value)
        checkForAutoUpdateManualBoost(updatedTemp: true)
	}
	
    func temperatureSliderChanged(value: Int) {
        let startTemp = startTemprature.value
        if UserDataManager.shared.temperatureUnit == .C {
			editingTemprature.value = value/2 + startTemp
			editingTempratureSmall.value = 0
        } else {
            editingTemprature.value = value + startTemp
            editingTempratureSmall.value = 0
        }
        
        
        guard let currentTemp = temperature.value.kld_doubleValue else {
            return
        }
        let targetTemp = Double(editingTemprature.value) + 0.1*Double(editingTempratureSmall.value)
        
        statusText.value = targetTemp > currentTemp ? "HEATING_TO_TEXT".app_localized.uppercased() : (targetTemp == currentTemp ? "" : "COOLING_DOWN_TEXT".app_localized.uppercased())
        statusImageName.value = targetTemp > currentTemp ? "ic-heating-up-small" : (targetTemp == currentTemp ? "" : "ic-cooling-down-small")
    }
    
    func manualBoostUpdate(completion: @escaping (Bool) -> Void) {
        guard let roomId = seletedRoom?.id else {
            completion(false)
            return
        }
        let time = Int(timeSliderValue.value)
        var temprature: Double = Double(editingTemprature.value) + Double(editingTempratureSmall.value) * 0.1
        if UserDataManager.shared.temperatureUnit == .F {
            temprature = temprature.celciusTemperature
        }
        let timeSetting = time > Constants.MAX_END_TIME_POINT ? 0 : time
        roomManager.manualBoostUpdate(roomId: roomId, temp: temprature, time: timeSetting, success: {
            Copilot.instance.report.log(event: UpdateManualBoostAnalyticsEvent(roomId: roomId, temp: temprature, time: timeSetting, screenName: self.screenName))
            completion(true)
        }, failure: { error in
            completion(false)
        })
    }
    
    func resetManualBoost(completion: @escaping (Bool, String) -> Void) {
        guard turnOnManualBoost.value && settingType == .MANUAL else {
            completion(false, "")
            if turnOnManualBoost.value {
                turnOnManualBoost.value = false
                refreshTempCircleSlider.onNext(())
                updateSettingTime(seconds: 0)
            } else {
                turnOnManualBoost.value = true
            }
            
            return
        }
        turnOnManualBoost.value = false
        if let room = seletedRoom {
            let roomViewModel = RoomViewModel.init(room: room)
            if roomViewModel.settingType == .MANUAL {
                settingManager.resetManualBoost(roomId: room.id, success: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    Copilot.instance.report.log(event: ResetManualBoostAnalyticsEvent(roomId: room.id, screenName: self.screenName))
                    completion(true, "")
                }) {  [weak self] _ in
                    self?.turnOnManualBoost.value = true
                    completion(false, "MANUAL_BOOST_CAN_NOT_RESET_MESS".app_localized)
                }
            } else {
                setup()
                completion(false, "")
            }
        }
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
    
	func checkForAutoUpdateManualBoost(updatedTemp: Bool) {
		guard let room = seletedRoom else {
			return
		}
		let roomViewModel = RoomViewModel.init(room: room)
		if updatedTemp {
			if settingType != .MANUAL && Int(timeSliderValue.value) == 0 {
				updateSettingTime(seconds: Constants.DEFAULT_BOOSTING_END_TIME_POINT)
			}
			let time = Int(timeSliderValue.value)
			let editTemprature: Double = Double(editingTemprature.value) + Double(editingTempratureSmall.value) * 0.1
			let currentTemprature: Double = Double(roomViewModel.settingTemprature.0) + Double(roomViewModel.settingTemprature.1) * 0.1
			guard time > 0 && currentTemprature != editTemprature else {
				return
			}
			performBoosting.onNext(())
		} else if settingType == .MANUAL  && roomViewModel.endTimePoint != Int(timeSliderValue.value) {
			performBoosting.onNext(())
		}
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
        if(timeSliderValue.value > 0) {
            timeSliderValue.value = timeSliderValue.value -  1
            countDownTime.value = Int(timeSliderValue.value).fullTimeFormart()
        } else {
            manualBoostTimeout.onNext(())
            stopTimer()
        }
    }
    ///-------
    
	private func increaseTemp() {
		let maxTemp = UserDataManager.shared.temperatureUnit == .C ? Constants.MAX_TEMPERATURE : Constants.MAX_TEMPERATURE.fahrenheitTemperature
		guard editingTemprature.value < Int(maxTemp) else {
			return
		}
		editingTemprature.value = editingTemprature.value + 1
	}
	
	private func decreaseTemp() {
		let minTemp = UserDataManager.shared.temperatureUnit == .C ? Constants.MIN_TEMPERATURE : Constants.MIN_TEMPERATURE.fahrenheitTemperature
		guard editingTemprature.value > Int(minTemp) else {
			return
		}
		editingTemprature.value = editingTemprature.value - 1
	}
	
    func turnOnOrOffScheduleMode(completion: @escaping (Bool, String) -> Void) {
        if currentSelectedMode != .SMARTSCHEDULE { // will turn on Schedule
            guard let isExitingSmartSchedule = exitingSmartSchedule else {
                completion(false, "")
                return
            }
            if !isExitingSmartSchedule {
                completion(false, "THERE_IS_NO_SCHEDULE_MESS".app_localized)
            } else {
                turnOnSchedule(afterTurnOffSmartMode: currentSelectedMode != .DEFAULT) { [weak self] isSuccess in
                    if isSuccess {
                        completion(true, "")
                    } else {
                        completion(false, "CAN_NOT_UPDATE_SCHEDULE_MODE_MESS".app_localized)
                    }
                }
            }
        } else {
            callServiceTurnOnOrOffSmartSchedule(isOn: false) { [weak self] isSuccess in
                if isSuccess {
                    completion(true, "")
                } else {
                    completion(false, "CAN_NOT_UPDATE_SCHEDULE_MODE_MESS".app_localized)
                }
            }
        }
    }
    
	private func loadCurrentSliderTemperature(temp: Int) {
		if UserDataManager.shared.temperatureUnit == .C {
			startTemprature.value = Int(Constants.MIN_TEMPERATURE)
			endTemprature.value = Int(Constants.MAX_TEMPERATURE)
			temperatureSliderRange = [Int](0...(endTemprature.value - startTemprature.value)*2)
			let temp = temp - startTemprature.value
			currentValueSlider = temp > 0 ? temp*2 : 0
		} else {
			startTemprature.value = Int(Constants.MIN_TEMPERATURE.fahrenheitTemperature)
			endTemprature.value = Int(Constants.MAX_TEMPERATURE.fahrenheitTemperature)
			temperatureSliderRange = [Int](0...(endTemprature.value - startTemprature.value))
			let temp = temp - startTemprature.value
			currentValueSlider = temp > 0 ? temp : 0
		}
		refreshTempCircleSlider.onNext(())
    }
    
    private func callServiceToUpdateMode(mode: SmartMode, completion: @escaping (Bool) -> Void) {
        guard let roomId = seletedRoom?.id else {
            completion(false)
            return
        }
        settingManager.updateSettingMode(mode: mode.rawValue, roomId: roomId, success: {
            Copilot.instance.report.log(event: SetModeAnalyticsEvent(roomId: roomId, mode: mode.rawValue, screenName: self.screenName))
            completion(true)
        }) { error in
            completion(false)
        }
    }
    
    private func getExistingSmartSchedule() {
        guard let roomId = seletedRoom?.id else {
            return
        }
        schedulesManager.checkExistingSmartSchedules(roomId: roomId) { [weak self] isExisting in
            self?.exitingSmartSchedule =  isExisting
        }
    }
    
    private func turnOnSchedule(afterTurnOffSmartMode: Bool, completion: @escaping (Bool) -> Void) {
        if afterTurnOffSmartMode {
            callServiceToUpdateMode(mode: .DEFAULT) { [weak self] isSuccess in
                guard isSuccess else {
                    completion(false)
                    return
                }
                
                guard let `self` = self else {
                    completion(false)
                    return
                }
                
                if self.enableSchedule {
                    completion(isSuccess)
                } else {
                    self.callServiceTurnOnOrOffSmartSchedule(isOn: true, completion: { isSuccess in
                        completion(isSuccess)
                    })
                }
            }
        } else {
            if self.enableSchedule {
                completion(true)
            } else {
                self.callServiceTurnOnOrOffSmartSchedule(isOn: true, completion: { isSuccess in
                    completion(isSuccess)
                })
            }
        }
    }
    
    private func callServiceTurnOnOrOffSmartSchedule(isOn: Bool, completion: @escaping (Bool) -> Void) {
        guard let roomId = seletedRoom?.id else {
            return
        }
        schedulesManager.turnOnOrOffSmartSchedule(roomId: roomId, turnOn: isOn, success: {
            completion(true)
        }) { error in
            completion(false)
        }
    }
}
