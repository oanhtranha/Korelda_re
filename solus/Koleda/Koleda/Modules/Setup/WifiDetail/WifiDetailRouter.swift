//
//  WifiDetailRouter.swift
//  Koleda
//
//  Created by Oanh tran on 12/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class WifiDetailRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case energyTariff
        case back
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
        case .energyTariff:
            let router = EnergyTariffRouter()
            let viewModel = EnergyTariffViewModel.init(router: router)
            guard let energyTariffVC = StoryboardScene.Setup.instantiateEnergyTariffViewController() as? EnergyTariffViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            energyTariffVC.viewModel = viewModel
            router.baseViewController = energyTariffVC
            baseViewController.navigationController?.pushViewController(energyTariffVC, animated: true)
        case .back:
            baseViewController.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
