//
//  JoinHomeRouter.swift
//  Koleda
//
//  Created by Oanh Tran on 6/24/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation

class JoinHomeRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case termAndConditions
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
        case .termAndConditions:
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
