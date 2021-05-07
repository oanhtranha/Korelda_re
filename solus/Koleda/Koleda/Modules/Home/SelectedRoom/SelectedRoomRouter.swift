//
//  SelectedRoomRouter.swift
//  Koleda
//
//  Created by Oanh tran on 8/26/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class SelectedRoomRouter: BaseRouterProtocol {
    
    enum RouteType {
        case configuration(Room)
        case manualBoost(Room)
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
        case .configuration(let selectedRoom):
            let router = ConfigurationRoomRouter()
            let viewModel = ConfigurationRoomViewModel.init(router: router, seletedRoom: selectedRoom)
            guard let viewController = StoryboardScene.Home.instantiateConfigurationRoomViewController() as? ConfigurationRoomViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .manualBoost(let selectedRoom):
            let router = ManualBoostRouter()
            let viewModel = ManualBoostViewModel.init(router: router, seletedRoom: selectedRoom)
            guard let viewController = StoryboardScene.Home.instantiateManualBoostViewController() as? ManualBoostViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            viewController.modalPresentationStyle = .overCurrentContext
            baseViewController.present(viewController, animated: true, completion: nil)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    
}
