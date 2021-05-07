
//
//  HomeViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 6/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD
import CopilotAPIAccess

protocol HomeViewModelProtocol: BaseViewModelProtocol {
    func addRoom()
    func getCurrentUser()
    func refreshListRooms()
    func refreshSettingModes()
    func selectedRoom(at indexPath: IndexPath)
    func selectedRoomConfiguration(at indexPath: IndexPath)
    func showMenuSettings()
    func logOut()
    var homeTitle: Variable<String> { get }
    var rooms: Variable<[Room]> { get }
    var mustLogOutApp: PublishSubject<String> { get }
    
}

class HomeViewModel: BaseViewModel, HomeViewModelProtocol {
    
    let homeTitle = Variable<String>("")
    let rooms = Variable<[Room]>([])
    let mustLogOutApp = PublishSubject<String>()
    let router: BaseRouterProtocol
    private let userManager: UserManager
    private let roomManager: RoomManager
    private let settingManager: SettingManager
    private let websocketManager: WebsocketManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router = router
        userManager =  managerProvider.userManager
        roomManager = managerProvider.roomManager
        settingManager = managerProvider.settingManager
        websocketManager = managerProvider.websocketManager
        super.init(managerProvider: managerProvider)
		setup()
        getAllRooms()
    }
    
	func setup() {
		if let currentUser = UserDataManager.shared.currentUser, currentUser.homes.count > 0 {
			reloadUser(userInfo: currentUser)
		} else {
			getCurrentUser()
		}
	}
	
    func addRoom() {
        router.enqueueRoute(with: HomeRouter.RouteType.addRoom)
    }
    
    func selectedRoomConfiguration(at indexPath: IndexPath) {
        let room = rooms.value[indexPath.section]
        router.enqueueRoute(with: HomeRouter.RouteType.selectedRoomConfiguration(room))
    }

    func selectedRoom(at indexPath: IndexPath) {
        let room = rooms.value[indexPath.section]
        router.enqueueRoute(with: HomeRouter.RouteType.selectedRoom(room))
    }
    
    func getCurrentUser() {
        SVProgressHUD.show()
        userManager.getCurrentUser(success: { [weak self] in
            guard let userId = UserDataManager.shared.currentUser?.id else {
                return
            }
            Copilot.instance
                .manage
                .yourOwn
                .sessionStarted(withUserId: userId,
                                isCopilotAnalysisConsentApproved: true)
            SVProgressHUD.dismiss()
			if let currentUser = UserDataManager.shared.currentUser, currentUser.homes.count > 0 {
				self?.reloadUser(userInfo: currentUser)
			}
        },
        failure: { error in
            SVProgressHUD.dismiss()
        })
    }
    
    func refreshSettingModes() {
        self.settingManager.loadSettingModes(success: { [weak self] in
            guard let `self` = self else {
                return
            }
            NotificationCenter.default.post(name: .KLDNeedReLoadModes, object: nil)
            self.refreshListRooms()
        }, failure: { error in })
    }
    
    func getAllRooms() {
        SVProgressHUD.show()
        roomManager.getRooms(success: { [weak self] in
            SVProgressHUD.dismiss()
            self?.rooms.value = UserDataManager.shared.rooms
            if let rooms = self?.rooms.value, rooms.count > 0 {
                self?.websocketManager.delegate = self
                self?.websocketManager.connect()
            }
            self?.getDeviceModelListFromRoomList()
            NotificationCenter.default.post(name: .KLDNeedUpdateSelectedRoom, object: nil)
        },
        failure: { [weak self] error in
            SVProgressHUD.dismiss()
            if let error = error as? WSError, error == WSError.loginSessionExpired, let errorMessage = error.errorDescription {
                self?.mustLogOutApp.onNext((errorMessage))
            }
        })
    }
    
    func refreshListRooms() {
        getAllRooms()
    }
    
    func showMenuSettings() {
        router.enqueueRoute(with: HomeRouter.RouteType.menuSettings)
    }
    
    func logOut() {
        SVProgressHUD.show()
        userManager.logOut { [weak self] in
            Copilot.instance
                .manage
                .yourOwn
                .sessionEnded()
            SVProgressHUD.dismiss()
            self?.router.enqueueRoute(with: HomeRouter.RouteType.logOut)
        }
    }
	
	private func reloadUser(userInfo: User) {
		let userName = userInfo.homes[0].name
		homeTitle.value = "<h1>\(userName)</h1>"
		UserDefaultsManager.termAndConditionAcceptedUser.value = UserDataManager.shared.currentUser?.email
		refreshSettingModes()
	}
    
    private func getDeviceModelListFromRoomList() {
        UserDataManager.shared.deviceModelList = []
        let allRooms = UserDataManager.shared.rooms
        var deviceModels: [String] = []
        allRooms.compactMap { room in
            if let sensor = room.sensor {
                deviceModels.append(sensor.deviceModel)
            }
            if let heaters = room.heaters, heaters.count > 0 {
                heaters.compactMap { heater in
                    deviceModels.append(heater.deviceModel)
                }
            }
        }
        UserDataManager.shared.deviceModelList = deviceModels
    }
}

extension HomeViewModel: WebsocketManagerDelegate {
    func refeshAtRoom(with newData: WSDataItem) {
        var listRooms = self.rooms.value
        var room = listRooms.filter { $0.sensor?.id == newData.id}.first
        let value = newData.value
        
        switch newData.name {
        case SocketKeyName.HUMIDITY.rawValue:
            room?.humidity = value as? String
        case SocketKeyName.BATTERY.rawValue:
            room?.battery = value as? String
        case SocketKeyName.TEMPERATURE.rawValue:
            room?.originalTemperature = value as? String
        case SocketKeyName.ROOM_STATUS.rawValue:
            room?.enabled =  value as? Bool
        default:
            break
        }
        if let row = listRooms.index(where: {$0.sensor?.id == newData.id}) , let newRoom = room {
            listRooms[row] = newRoom
            self.rooms.value = listRooms
        }
        NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
    }
}
