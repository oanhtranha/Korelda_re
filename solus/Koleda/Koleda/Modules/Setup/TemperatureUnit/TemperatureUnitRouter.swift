//
//  TemperatureUnitRouter.swift
//  Koleda
//
//  Created by Oanh tran on 9/17/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class TemperatureUnitRouter: BaseRouterProtocol {
    
    enum RouteType {
        case home
        case inviteFriends
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
        case .inviteFriends:
            let router = InviteFriendsRouter()
            let viewModel = InviteFriendsViewModel.init(router: router)
            guard let viewController = StoryboardScene.Setup.instantiateInviteFriendsViewController() as? InviteFriendsViewController else {
                assertionFailure("InviteFriendsViewController storyboard configured not properly")
                return
            }
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
