//
//  InstructionForHeaterRouter.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/6/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class InstructionForHeaterRouter: BaseRouterProtocol {
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
    
    func nextToAddHeater(roomId: String, roomName: String, isFromRoomConfiguration: Bool) {
        baseViewController?.gotoBlock(withStoryboar: "Heater", aClass: AddHeaterViewController.self) { (vc) in
            let router = AddHeaterRouter()
            let viewModel = AddHeaterViewModel.init(router: router, roomId: roomId, roomName: roomName)
            vc?.viewModel = viewModel
            vc?.isFromRoomConfiguration = isFromRoomConfiguration
            router.baseViewController = vc
        }
    }

}
