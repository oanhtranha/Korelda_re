//
//  InviteFriendsViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 6/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol InviteFriendViewModelProtocol: BaseViewModelProtocol {
	
	func showHomeScreen()
	func inviteFriends()
}

class InviteFriendsViewModel: BaseViewModel, InviteFriendViewModelProtocol {
	let router: BaseRouterProtocol
	
	init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
		self.router = router
		super.init(managerProvider: managerProvider)
	}
	
	func showHomeScreen() {
        UserDefaultsManager.loggedIn.enabled = true
		router.enqueueRoute(with: InviteFriendsRouter.RouteType.home)
	}
	
	func inviteFriends() {
		router.enqueueRoute(with: InviteFriendsRouter.RouteType.inviteFriendsDetail)
	}
	
}
