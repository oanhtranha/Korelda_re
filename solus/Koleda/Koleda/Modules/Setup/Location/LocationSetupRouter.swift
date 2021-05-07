//
//  LocationSetupRouter.swift
//  Koleda
//
//  Created by Oanh tran on 7/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class LocationSetupRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case decline
		case wifiSetup
        case welcomeJoinHome
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
        case .decline:
            let router = OnboardingRouter()
            let viewModel = OnboardingViewModel.init(with: router)
            let onboaringNavigationVC = StoryboardScene.Onboarding.instantiateNavigationController()
            
            guard let viewController = onboaringNavigationVC.topViewController as? OnboardingViewController else {
                assertionFailure("OnBoarding storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.window?.rootViewController = onboaringNavigationVC
            }
		case .wifiSetup:
			let router = WifiSetupRouter()
			let viewModel =  WifiSetupViewModel.init(router: router)
			
			guard let viewController = StoryboardScene.Setup.instantiateWifiSetupViewController() as? WifiSetupViewController else {
				assertionFailure("Setup storyboard configured not properly")
				return
			}
			viewController.viewModel = viewModel
			router.baseViewController = viewController
			baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .welcomeJoinHome:
            let router = WelcomeJoinHomeRouter()
            let viewModel =  WelcomeJoinHomeViewModel.init(router: router)
            
            guard let viewController = StoryboardScene.Onboarding.instantiateWelcomeJoinHomeViewController() as? WelcomeJoinHomeViewController else {
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
