//
//  SyncRouter.swift
//  Koleda
//
//  Created by Oanh tran on 6/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class SyncRouter: BaseRouterProtocol {
    
    enum RouteType {
        case termAndCondition
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
        case .termAndCondition:
            let router = TermAndConditionRouter()
            let viewModel = TermAndConditionViewModel.init(router: router)
            guard let viewController = StoryboardScene.Setup.instantiateTermAndConditionViewController() as? TermAndConditionViewController else { return }
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
