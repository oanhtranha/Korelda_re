//
//  EnergyTariffRouter.swift
//  Koleda
//
//  Created by Oanh tran on 7/31/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class EnergyTariffRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case temperatureUnit
        case backHome
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
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
        case .temperatureUnit:
            let router = TemperatureUnitRouter()
            let viewModel = TemperatureUnitViewModel.init(router: router)
            guard let viewController = StoryboardScene.Setup.instantiateTemperatureUnitViewController() as? TemperatureUnitViewController else {
                assertionFailure("TemperatureUnitViewController storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .backHome:
            baseViewController.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
