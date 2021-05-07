//
//  WifiSetupRouter.swift
//  Koleda
//
//  Created by Oanh tran on 7/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class WifiSetupRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case wifiDetail
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
        case .wifiDetail:
        let router = WifiDetailRouter()
        let viewModel = WifiDetailViewModel.init(router: router)
        guard let wifiDetailVC = StoryboardScene.Setup.instantiateWifiDetailViewController() as? WifiDetailViewController else {
            assertionFailure("Setup storyboard configured not properly")
            return
        }
        wifiDetailVC.viewModel = viewModel
        router.baseViewController = wifiDetailVC
        baseViewController.navigationController?.pushViewController(wifiDetailVC, animated: true)
    }
        
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
