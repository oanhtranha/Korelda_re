//
//  TermAndConditionRouter.swift
//  Koleda
//
//  Created by Oanh tran on 7/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class TermAndConditionRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case location
        case createHome
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
        case .location:
            let router = LocationSetupRouter()
            let viewModel = LocationSetupViewModel.init(router: router)
            guard let viewController = StoryboardScene.Setup.LocationSetupViewController.viewController() as? LocationSetupViewController else { return }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .createHome:
            let router = CreateHomeRouter()
            let viewModel =  CreateHomeViewModel.init(router: router)
            
            guard let viewController = StoryboardScene.Setup.instantiateCreateHomeViewController() as? CreateHomeViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
}
