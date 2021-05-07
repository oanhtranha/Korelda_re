//
//  Launcher.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import SVProgressHUD

class Launcher {
    
    private var loginAppManager: LoginAppManager {
        return ManagerProvider.sharedInstance.loginAppManager
    }
    
    func displayScreenBaseOnUserStatus(on window: UIWindow) {
        if loginAppManager.isLoggedIn {
            presentHomeScreen(on: window)
        } else {
            presentOnboardingScreen(on: window)
        }
    }
    
    func presentOnboardingScreen(on window: UIWindow) {
        let router = OnboardingRouter()
        let navigationVC = StoryboardScene.Onboarding.instantiateNavigationController()
        let viewModel = OnboardingViewModel.init(with: router)
        
        guard let viewController = navigationVC.topViewController as? OnboardingViewController else {
            assertionFailure("Onboarding storyboard configured not properly")
            return
        }
        
        viewController.viewModel = viewModel
        router.baseViewController = viewController
        window.rootViewController = navigationVC
        
    }
    
    func presentHomeScreen(on window: UIWindow) {
        let router = HomeRouter()
        let viewModel = HomeViewModel.init(router: router)
        let homeNavigationVC = StoryboardScene.Home.instantiateNavigationController()
        
        guard let viewController = homeNavigationVC.topViewController as? HomeViewController else {
            assertionFailure("Home storyboard configured not properly")
            return
        }
        viewController.viewModel = viewModel
        router.baseViewController = viewController
        window.rootViewController = homeNavigationVC
    }
}
