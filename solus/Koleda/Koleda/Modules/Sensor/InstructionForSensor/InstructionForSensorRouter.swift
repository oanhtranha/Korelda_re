//
//  InstructionForSensorRouter.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/6/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class InstructionForSensorRouter: BaseRouterProtocol {
    var baseViewController: UIViewController?
    
    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
    }

    func backToRoot() {
        baseViewController?.backToRoot(animated: true)
    }
    
    func nextToSensorManagement(roomId: String, roomName: String, isFromRoomConfiguration: Bool) {
        baseViewController?.gotoBlock(withStoryboar: "Sensor", aClass: SensorManagementViewController.self) { (vc) in
            let router = SensorManagementRouter()
            let viewModel = SensorManagementViewModel.init(router: router, roomId: roomId, roomName: roomName)
            vc?.viewModel = viewModel
            vc?.isFromRoomConfiguration = isFromRoomConfiguration
            router.baseViewController = vc
        }
    }
}
