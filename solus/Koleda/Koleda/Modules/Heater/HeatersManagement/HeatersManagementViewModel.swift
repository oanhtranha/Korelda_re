
//
//  HeatersManagementViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import CopilotAPIAccess

protocol HeatersManagementViewModelProtocol: BaseViewModelProtocol {
    var pairedWithHeatersTitle: Variable<String> { get }
    var heaters: Variable<[Heater]>  { get }
    var showDeleteConfirmMessage: PublishSubject<Bool> { get }
    var removingHeaterName: String?  { get }
    func viewWillAppear()
    func updatePairedWithHeatersTitle(heaters: [Heater])
    func removeHeater(by heater: Heater)
    func callServiceDeleteHeater(completion: @escaping (Bool) -> Void)
    func doneAction()
    func addHeaterFlow()
    func needUpdateSelectedRoom()
}

class HeatersManagementViewModel: BaseViewModel, HeatersManagementViewModelProtocol  {
    
    let router: BaseRouterProtocol
    let pairedWithHeatersTitle = Variable<String>("")
    let heaters = Variable<[Heater]>([])
    let showDeleteConfirmMessage = PublishSubject<Bool>()
    
    private let shellyDeviceManager: ShellyDeviceManager
    private var selectedRoom: Room
    private var removingHeaterId: String?
    var removingHeaterName: String?
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, selectedRoom: Room) {
        self.router = router
        self.shellyDeviceManager = managerProvider.shellyDeviceManager
        self.selectedRoom = selectedRoom
        super.init(managerProvider: managerProvider)
    }
    
    func viewWillAppear() {
        let roomViewModel = RoomViewModel.init(room: selectedRoom)
        if let heaters = roomViewModel.heaters, heaters.count > 0 {
            updatePairedWithHeatersTitle(heaters: heaters)
        } else {
            updatePairedWithHeatersTitle(heaters: [])
        }
    }
    
    func updatePairedWithHeatersTitle(heaters: [Heater]) {
        self.heaters.value = heaters
        if heaters.count > 0 {
            pairedWithHeatersTitle.value = String(format: "SENSOR_IS_PAIRED_WITH_HEATERS_MESS".app_localized, selectedRoom.name)
        } else {
            pairedWithHeatersTitle.value = String(format: "SENSOR_IS_NOT_PAIRED_ANY_HEATER_MESS".app_localized, selectedRoom.name)
        }
    }
    
    func removeHeater(by heater: Heater) {
        removingHeaterId = heater.id
        removingHeaterName = heater.name
        showDeleteConfirmMessage.onNext(true)
    }
    
    func callServiceDeleteHeater(completion: @escaping (Bool) -> Void) {
        guard let heaterId = removingHeaterId else {
            return
        }
        shellyDeviceManager.deleteDevice(roomId: selectedRoom.id, deviceId: heaterId, success: { [weak self] in
            guard var allHeaters = self?.heaters.value, allHeaters.count > 0 else {
                completion(true)
                return
            }
            guard let `self` = self else {
                return
            }
            allHeaters.removeAll { $0.id == heaterId }
            self.updatePairedWithHeatersTitle(heaters: allHeaters)
            Copilot.instance.report.log(event: RemoveHeaterAnalyticsEvent(heaterId: heaterId, screenName: self.screenName))
            completion(true)
        },failure:  { error in
            completion(false)
        })
    }
    
    func doneAction() {
        router.enqueueRoute(with: HeatersManagementRouter.RouteType.done)
    }
    
    func addHeaterFlow() {
        router.enqueueRoute(with: HeatersManagementRouter.RouteType.addHeaterFlow(self.selectedRoom.id, self.selectedRoom.name))
    }
    
    func needUpdateSelectedRoom() {
        let room = UserDataManager.shared.roomWith(roomId: selectedRoom.id)
        guard let updatedRoom = room else {
            return
        }
        selectedRoom = updatedRoom
        viewWillAppear()
    }
}
