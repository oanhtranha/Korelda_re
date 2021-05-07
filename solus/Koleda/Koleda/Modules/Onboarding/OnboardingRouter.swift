//
//  OnboardingRouter.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class OnboardingRouter: BaseRouterProtocol {
    
    enum RouteType {
        case signUp
        case logIn
		case joinHome
        case termAndConditions
		case home
		case createHome
		
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
        case .signUp:
            baseViewController.performSegue(withIdentifier: SignUpViewController.get_identifier, sender: self)
        case .logIn:
            let router = LoginRouter()
            guard let viewController = StoryboardScene.Login.initialViewController() as? LoginViewController else { return }
            let viewModel = LoginViewModel.init(router: router)
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
		case .joinHome:
			let router = JoinHomeRouter()
			let viewModel = JoinHomeViewModel.init(router: router)
			guard let viewController = StoryboardScene.Onboarding.instantiateJoinHomeViewController() as? JoinHomeViewController else {
				return
			}
			viewController.viewModel = viewModel
			router.baseViewController = viewController
			baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .termAndConditions:
            let router = TermAndConditionRouter()
            let viewModel = TermAndConditionViewModel.init(router: router)
            guard let viewController = StoryboardScene.Setup.instantiateTermAndConditionViewController() as? TermAndConditionViewController else { return }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
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
		case .createHome:
			let router = CreateHomeRouter()
			let viewModel = CreateHomeViewModel.init(router: router)
			guard let createHomeViewController = StoryboardScene.Setup.instantiateCreateHomeViewController() as? CreateHomeViewController else { return }
			createHomeViewController.viewModel = viewModel
			router.baseViewController = createHomeViewController
			baseViewController.navigationController?.pushViewController(createHomeViewController, animated: true)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func prepare(for segue: UIStoryboardSegue) {
        if let viewController = segue.destination as? SignUpViewController {
            let router = SignUpRouter()
            let viewModel = SignUpViewModel.init(router: router)
            viewController.viewModel = viewModel
            router.baseViewController = viewController
        }
    }
}
