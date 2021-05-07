//
//  EditSensorViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import CopilotAPIAccess

protocol EditSensorViewModelProtocol: BaseViewModelProtocol {
    var sensorName: Variable<String> { get }
    var sensorStatus: Variable<Bool> { get }
    var nPairedHeaters:Variable<Int> { get }
    var pairedWithHeaters: Variable<String> { get }
    var sensorModel: Variable<String> { get }
    var roomName: Variable<String> { get }
    var temperature: Variable<String> { get }
    var humidity: Variable<String> { get }
    var battery: Variable<String> { get }
    func needUpdateSelectedRoom()
    func deleteSensor(completion: @escaping (Bool) -> Void)
    func backToHome()
}

class EditSensorViewModel: BaseViewModel, EditSensorViewModelProtocol  {
    
    let router: BaseRouterProtocol
    let sensorName = Variable<String>("")
    let sensorStatus = Variable<Bool>(false)
    var nPairedHeaters = Variable<Int>(0)
    let pairedWithHeaters = Variable<String>("")
    let sensorModel = Variable<String>("")
    let roomName = Variable<String>("")
    let temperature = Variable<String>("")
    let humidity = Variable<String>("")
    let battery = Variable<String>("")
    
    
    private let shellyDeviceManager: ShellyDeviceManager
    private var room: Room
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, seletedRoom: Room) {
        self.router = router
        self.shellyDeviceManager = managerProvider.shellyDeviceManager
        self.room = seletedRoom
        super.init(managerProvider: managerProvider)
        setup()
    }
    
    private func setup() {
        let roomViewModel = RoomViewModel.init(room: room)
        if  let sensor = roomViewModel.sensor {
            sensorStatus.value = sensor.enabled
            sensorModel.value = sensor.deviceModel
        }
        let heatersNumber = roomViewModel.heaters?.count ?? 0
        sensorName.value = "\(roomViewModel.roomName) Sensor".app_localized
        
        pairedWithHeaters.value = heatersNumber > 0 ? String(format: "NUMBER_HEATERS_CONNECTED_MESS".app_localized, heatersNumber) : "NOT_PAIRED_WITH_ANY_SOLUS_MESS".app_localized
        nPairedHeaters.value = heatersNumber
        roomName.value = String(format: "ROOM_SENSOR_TEXT".app_localized, roomViewModel.roomName)
        temperature.value = roomViewModel.temprature
        
        temperature.value = roomViewModel.temprature
        humidity.value = roomViewModel.humidity
        battery.value = roomViewModel.sensorBattery
    }
    
    func needUpdateSelectedRoom() {
        if let room = UserDataManager.shared.roomWith(roomId: room.id) {
            self.room = room
            setup()
        }
    }
    
    func deleteSensor(completion: @escaping (Bool) -> Void) {
        guard let sensor = room.sensor else {
            return
        }
        shellyDeviceManager.deleteDevice(roomId: room.id ,deviceId: sensor.id, success: {
            Copilot.instance.report.log(event: RemoveSensorAnalyticsEvent(sensorId: sensor.id, screenName: self.screenName))
            completion(true)
        },
        failure: { error in
            completion(false)
        })
    }
    
    func backToHome() {
        router.enqueueRoute(with: EditSensorRouter.RouteType.backHome)
    }
}
