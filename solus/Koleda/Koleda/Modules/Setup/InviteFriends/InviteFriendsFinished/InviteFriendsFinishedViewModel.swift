//
//  InviteFriendsFinishedViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 6/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
protocol InviteFriendsFinishedViewModelProtocol: BaseViewModelProtocol {
	func showHomeScreen()
	func addMoreFriends()
}

class InviteFriendsFinishedViewModel: BaseViewModel, InviteFriendsFinishedViewModelProtocol {
	let router: BaseRouterProtocol
	
	init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
		self.router = router
		super.init(managerProvider: managerProvider)
	}
	
	func showHomeScreen() {
        UserDefaultsManager.loggedIn.enabled = true
        router.enqueueRoute(with: InviteFriendsFinishedRouter.RouteType.home)
	}
	
	func addMoreFriends() {
		router.enqueueRoute(with: InviteFriendsFinishedRouter.RouteType.back)
	}
}
