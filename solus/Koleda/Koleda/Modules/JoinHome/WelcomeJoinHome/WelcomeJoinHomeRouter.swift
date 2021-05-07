//
//  WelcomeJoinHomeRouter.swift
//  Koleda
//
//  Created by Oanh Tran on 8/5/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation

class WelcomeJoinHomeRouter: BaseRouterProtocol {
    
    enum RouteType {
        case home
    }
    
    weak var baseViewController: UIViewController?
    
    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
        
        guard let routeType = context as? RouteType else {
            assertionFailure("The route type missmatches")
            return
        }
        
        switch routeType {
        case .home:
            let router = HomeRouter()
            let viewModel = HomeViewModel.init(router: router)
            let homeNavigationVC = StoryboardScene.Home.instantiateNavigationController()
            
            guard let viewController = homeNavigationVC.topViewController as? HomeViewController else {
                assertionFailure("HomeViewController storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.window?.rootViewController = homeNavigationVC
            }
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
    }
    
    
}
