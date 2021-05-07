//
//  ConfigurationRoomRouter.swift
//  Koleda
//
//  Created by Oanh tran on 8/26/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ConfigurationRoomRouter: BaseRouterProtocol {
    
    enum RouteType {
        case editRoom(Room)
        case addSensor(String, String)
        case editSensor(Room)
        case heaterManagement(Room)
    }
    
    weak var baseViewController: UIViewController?
    
    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
        
        guard let routeType = context as? RouteType else {
            assertionFailure("The route type missmatches")
            return
        }
        
        guard let baseViewController = baseViewController else {
            assertionFailure("baseViewController is not set")
            return
        }
        switch routeType {
        case .editRoom(let selectedRoom):
            let router = RoomDetailRouter()
            let viewModel = RoomDetailViewModel.init(router: router, editingRoom: selectedRoom)
            guard let viewController = StoryboardScene.Room.instantiateRoomDetailViewController() as? RoomDetailViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .addSensor(let roomId, let roomName):
            baseViewController.gotoBlock(withStoryboar: "Sensor", aClass: InstructionViewController.self, sendData: { (vc) in
                vc?.roomId = roomId
                vc?.roomName = roomName
                vc?.isFromRoomConfiguration = true
            })
        case .editSensor(let selectedRoom):
            let router = EditSensorRouter()
            let viewModel = EditSensorViewModel.init(router: router, seletedRoom: selectedRoom)
            guard let viewController = StoryboardScene.Sensor.instantiateEditSensorViewController() as? EditSensorViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .heaterManagement(let selectedRoom):
            let router = HeatersManagementRouter()
            let viewModel = HeatersManagementViewModel.init(router: router, selectedRoom: selectedRoom)
            guard let viewController = StoryboardScene.Heater.instantiateHeatersManagementViewController() as? HeatersManagementViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    
}
