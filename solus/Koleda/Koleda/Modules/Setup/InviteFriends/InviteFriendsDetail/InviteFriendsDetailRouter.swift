//
//  InviteFriendsDetailRouter.swift
//  Koleda
//
//  Created by Oanh Tran on 6/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation

class InviteFriendsDetailRouter: BaseRouterProtocol {
	weak var baseViewController: UIViewController?
	
	enum RouteType {
		case invited
	}
	
	func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
		guard let baseViewController = baseViewController else {
			assertionFailure("he route type missmatches")
			return
		}
		
		guard let routeType = context as? RouteType else {
			assertionFailure("baseViewController is not set")
			return
		}
		
		switch routeType {
		case .invited:
			let router = InviteFriendsFinishedRouter()
			let viewModel = InviteFriendsFinishedViewModel.init(router: router)
			
			guard let viewController = StoryboardScene.Setup.instantiateInviteFriendsFinishedViewController() as? InviteFriendsFinishedViewController else {
				assertionFailure("Setup storyboard configured not properly")
				return
			}
			viewController.viewModel = viewModel
			router.baseViewController = viewController
			baseViewController.navigationController?.pushViewController(viewController, animated: true)
		default:
			break
		}
		
		
	}
	func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
		
	}
	
	func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
		
	}
}
