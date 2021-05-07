//
//  GuideRouter.swift
//  Koleda
//
//  Created by Oanh tran on 6/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class GuideRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case addSensor(String)
        case addHeater(String)
    }
    
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
        case .addSensor(let roomId):
            let router = SensorManagementRouter()
            guard let viewController = StoryboardScene.Sensor.instantiateSensorManagementViewController() as? SensorManagementViewController else { return }
            let viewModel = SensorManagementViewModel.init(router: router, roomId: roomId, roomName: "")
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .addHeater(let roomId):
            let router = AddHeaterRouter()
            guard let viewController = StoryboardScene.Heater.instantiateAddHeaterViewController() as? AddHeaterViewController else { return }
            let viewModel = AddHeaterViewModel.init(router: router, roomId: roomId, roomName: "")
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
