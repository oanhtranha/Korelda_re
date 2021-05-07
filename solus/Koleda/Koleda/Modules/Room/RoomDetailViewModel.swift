//
//  RoomDetailViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 7/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import CopilotAPIAccess

protocol RoomDetailViewModelProtocol: BaseViewModelProtocol {
    var screenTitle: Variable<String> { get }
    var roomTypes: Variable<[RoomType]>  { get }
    var roomName: Variable<String> { get }
    var roomNameErrorMessage: Variable<String> { get }
    var showPopUpSelectRoomType: PublishSubject<Bool> { get }
    var showPopUpSuccess: PublishSubject<Bool> { get }
    var hideDeleteButton: BehaviorSubject<Bool> { get }
    var selectedCategory: Variable<String> { get }
    var nextButtonTitle: Variable<String> { get }
    var currentRoomType: RoomType? { get }
    
    func viewWillAppear()
    func roomType(at indexPath: IndexPath?) -> RoomType?
    func roomType(with category: String) -> RoomType?
    func indexPathOfCategory(with category: String) -> IndexPath?
    func next(roomType: RoomType?, completion: @escaping () -> Void)
    func deleteRoom()
}

class RoomDetailViewModel: BaseViewModel, RoomDetailViewModelProtocol {
    let router: BaseRouterProtocol
    var currentRoomType :RoomType?
    let screenTitle = Variable<String>("ADD_A_ROOM_TEXT".app_localized)
    let roomTypes = Variable<[RoomType]>([])
    let roomName = Variable<String>("")
    let roomNameErrorMessage = Variable<String>("")
    let showPopUpSelectRoomType = PublishSubject<Bool>()
    let showPopUpSuccess = PublishSubject<Bool>()
    let hideDeleteButton = BehaviorSubject<Bool>(value: true)
    let selectedCategory = Variable<String>("")
    let nextButtonTitle = Variable<String>("CREATE_ROOM_TEXT".app_localized)
    
    private var editingRoom: Room?
    private var roomManager: RoomManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, editingRoom: Room? = nil) {
        self.router = router
        self.roomManager = managerProvider.roomManager
        self.editingRoom = editingRoom
        super.init(managerProvider: managerProvider)
        self.roomTypes.value = RoomType.initRoomTypes()
        if let category = editingRoom?.category {
            self.currentRoomType = roomType(with: category)
        }
    }
    
    func viewWillAppear() {
        guard let name = editingRoom?.name, let category = editingRoom?.category else {
            return
        }
        screenTitle.value = "EDIT_ROOM_TEXT".app_localized
        nextButtonTitle.value = "CONFIRM_ROOM_DETAILS_TEXT".app_localized
        roomName.value = name
        selectedCategory.value = category
        hideDeleteButton.onNext(false)
    }
    
    func roomType(at indexPath: IndexPath?) -> RoomType? {
        guard let selectedIndexpath = indexPath else {
            return nil
        }
        return roomTypes.value[selectedIndexpath.item]
    }
    
    func roomType(with category: String) -> RoomType? {
        let roomCategory = RoomCategory(fromString: category)
        return roomTypes.value.filter { $0.category == roomCategory}.first
    }
    
    func indexPathOfCategory(with category: String) -> IndexPath? {
        guard let roomType = self.roomType(with: category), let item = roomTypes.value.firstIndex(where: { $0 == roomType }) else { return nil }
        return IndexPath(item: item, section: 0)
    }
    
    func next(roomType: RoomType?, completion: @escaping () -> Void) {
        guard let type = roomType else {
            self.showPopUpSelectRoomType.onNext(true)
            completion()
            return
        }
        let roomName = self.roomName.value.extraWhitespacesRemoved
        let categoryString = type.category.rawValue
        if validateRoomName() {
            guard let editingRoom = editingRoom else {
                addRoom(category: categoryString, name: roomName, completion: {
                    completion()
                })
                return
            }
            if editingRoom.name != roomName || editingRoom.category != type.category.rawValue {
                updateRoom(roomId: editingRoom.id, category: categoryString, name: roomName, completion: {
                    completion()
                })
            } else {
                completion()
            }
        }
    }
    
    func deleteRoom() {
        guard let roomId = self.editingRoom?.id else {
            return
        }
        roomManager.deleteRoom(roomId: roomId, success: { [weak self] in
            guard let `self` = self else {
                return
            }
            NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
            self.router.dismiss(animated:true, context: RoomDetailRouter.RouteType.deleted, completion: nil)
            Copilot.instance.report.log(event: removeRoomAnalyticsEvent(roomId: roomId, roomName: self.editingRoom?.name ?? "", homeId: UserDataManager.shared.currentUser?.homes[0].id ?? "" , screenName: self.screenName))
        },
        failure: { error in })
    }
}

extension RoomDetailViewModel {
    
    private func validateRoomName() -> Bool {
        if roomName.value.extraWhitespacesRemoved.isEmpty {
            roomNameErrorMessage.value = "ROOM_NAME_IS_NOT_EMPTY_MESS".app_localized
            return false
        } else {
            roomNameErrorMessage.value = ""
            return true
        }
    }
    
    private func addRoom(category: String, name: String, completion: @escaping () -> Void) {
        
        roomManager.createRoom(category: category, name: name, success: { [weak self] roomId in
            guard let `self` = self else {
                return
            }
            NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
            self.router.enqueueRoute(with: RoomDetailRouter.RouteType.added(roomId, name))
            Copilot.instance.report.log(event: AddRoomAnalyticsEvent(roomName: name, homeId: UserDataManager.shared.currentUser?.homes[0].id ?? "", screenName: self.screenName))
            completion()
        },
        failure: { _ in
            completion()
        })
    }
    
    private func updateRoom(roomId: String, category: String, name: String, completion: @escaping () -> Void) {
        roomManager.updateRoom(roomId: roomId, category: category, name: name, success: { [weak self] in
            guard let `self` = self else {
                return
            }
            NotificationCenter.default.post(name: .KLDDidChangeRooms, object: nil)
            self.router.dismiss(animated: true, context: RoomDetailRouter.RouteType.updated, completion: nil)
            Copilot.instance.report.log(event: editRoomAnalyticsEvent(roomId: roomId, roomName: name, homeId: UserDataManager.shared.currentUser?.homes[0].id ?? "", screenName: self.screenName))
            completion()
        },
        failure: { error in
            completion()
        })
    }
    
    
}
