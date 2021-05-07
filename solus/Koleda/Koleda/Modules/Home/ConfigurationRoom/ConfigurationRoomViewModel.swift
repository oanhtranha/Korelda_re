//
//  ConfigurationRoomViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 8/26/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift

protocol ConfigurationRoomViewModelProtocol: BaseViewModelProtocol {
    var title: Variable<String> { get }
    var roomName: Variable<String> { get }
    var temperature: Variable<String> { get }
    var pairedWithSensorTitle: Variable<String> { get }
    var pairedWithHeatersTitle: Variable<String> { get }
    var enableHeaterManagement: PublishSubject<Bool> { get }
    var imageRoom: PublishSubject<UIImage> { get }
    var heaters: Variable<[Heater]>  { get }
    var imageRoomColor : PublishSubject<UIColor> { get }
    func setup()
    func editRoom()
    func sensorManagement()
    func heatersManagement()
    func needUpdateSelectedRoom()
}

class ConfigurationRoomViewModel: BaseViewModel, ConfigurationRoomViewModelProtocol {
    let title = Variable<String>("")
    let roomName = Variable<String>("")
    var temperature = Variable<String>("")
    let pairedWithSensorTitle = Variable<String>("")
    let pairedWithHeatersTitle = Variable<String>("")
    let enableHeaterManagement = PublishSubject<Bool>()
    let imageRoom = PublishSubject<UIImage>()
    let imageRoomColor = PublishSubject<UIColor>()
    var heaters = Variable<[Heater]>([])
    
    let router: BaseRouterProtocol
    private let roomManager: RoomManager
    private var seletedRoom: Room?
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, seletedRoom: Room? = nil) {
        self.router = router
        self.roomManager = managerProvider.roomManager
        self.seletedRoom = seletedRoom
        super.init(managerProvider: managerProvider)
    }
    
    func setup() {
        guard let userName = UserDataManager.shared.currentUser?.name, let room = seletedRoom else {
            return
        }
        let roomViewModel = RoomViewModel.init(room: room)
        title.value = "\(userName)’s \(roomViewModel.roomName)"
        roomName.value = roomViewModel.roomName
        if let image = roomViewModel.roomConfigurationImage {
            imageRoom.onNext(image)
        }
        imageRoomColor.onNext(roomViewModel.onOffSwitchStatus ? UIColor.black : UIColor.gray)
        
        guard let sensor = roomViewModel.sensor else {
            pairedWithSensorTitle.value = String(format: "ROOM_NOT_CONNECT_TO_ANY_SENSOR_MESS".app_localized, roomViewModel.roomName)
            pairedWithHeatersTitle.value = ""
            enableHeaterManagement.onNext(false)
            return
        }
        if let temp = roomViewModel.currentTemp {
            temperature.value = "\(temp)"
        } else {
            temperature.value = "-"
        }
        
        enableHeaterManagement.onNext(true)
        pairedWithSensorTitle.value = String(format: "PAIRED_WITH_SENSOR_MESS".app_localized, roomViewModel.roomName)
        guard let heaters = roomViewModel.heaters, heaters.count > 0 else {
            pairedWithHeatersTitle.value = String(format: "SENSOR_NOT_CONNECT_TO_ANY_HEATER_MESS".app_localized, roomViewModel.roomName)
            self.heaters.value = []
            return
        }
        self.heaters.value = heaters
        pairedWithHeatersTitle.value = String(format: "SENSOR_PAIRED_WITH_HEATERS_MESS".app_localized, roomViewModel
                                                .roomName)
    
    }
    
    func editRoom() {
        guard let room = seletedRoom else {
            return
        }
        router.enqueueRoute(with: ConfigurationRoomRouter.RouteType.editRoom(room))
    }
    
    func sensorManagement() {
        guard let room = seletedRoom else {
            return
        }
        guard let sensor = seletedRoom?.sensor else {
            router.enqueueRoute(with: ConfigurationRoomRouter.RouteType.addSensor(room.id, room.name))
            return
        }
        router.enqueueRoute(with: ConfigurationRoomRouter.RouteType.editSensor(room))
    }
    
    func heatersManagement() {
        guard let room = seletedRoom else {
            return
        }
        router.enqueueRoute(with: ConfigurationRoomRouter.RouteType.heaterManagement(room))
    }
    
    func needUpdateSelectedRoom() {
        if let roomId = seletedRoom?.id, let room = UserDataManager.shared.roomWith(roomId: roomId) {
            seletedRoom = room
            setup()
        }
    }
}
