//
//  LoginRouter.swift
//  Koleda
//
//  Created by Oanh tran on 6/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class LoginRouter: BaseRouterProtocol {
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case home
        case syncUser
        case termAndConditions
        case forgotPassword
        case onboaring
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
        case .syncUser:
            let router = SyncRouter()
            guard let viewController = StoryboardScene.Setup.initialViewController() as? SyncViewController else { return }
            let viewModel = SyncViewModel.init(with: router)
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .forgotPassword:
            baseViewController.gotoBlock(withStoryboar: "Login", aClass: ForgotPasswordViewController.self) { (vc) in
                if let viewController = vc {
                    let router = ForgotPasswordRouter()
                    let viewModel = ForgotPasswordViewModel.init(router: router)
                    viewController.viewModel = viewModel
                    router.baseViewController = viewController
                }
            }
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
        case .onboaring:
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
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func prepare(for segue: UIStoryboardSegue) {
        if let viewController = segue.destination as? ForgotPasswordViewController {
            let router = ForgotPasswordRouter()
            let viewModel = ForgotPasswordViewModel.init(router: router)
            viewController.viewModel = viewModel
            router.baseViewController = viewController
        }
    }
}
