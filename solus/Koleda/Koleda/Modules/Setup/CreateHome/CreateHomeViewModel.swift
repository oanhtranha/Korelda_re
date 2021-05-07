//
//  CreateHomeViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 6/16/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol CreateHomeViewModelProtocol: BaseViewModelProtocol {
	
	var welcomeMessage : Variable<String> { get}
	var homeName: Variable<String> { get }
	var homeNameErrorMessage: Variable<String> { get }
	func saveAction(completion: @escaping () -> Void)
}

class CreateHomeViewModel: BaseViewModel, CreateHomeViewModelProtocol {
	let router: BaseRouterProtocol
	
	let welcomeMessage = Variable<String>("Welcome to SOLUS!\nCreate your <h1>Home</h1>")
	let homeName = Variable<String>("")
	let homeNameErrorMessage = Variable<String>("")
	
	private let homeManager: HomeManager
	
	init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
		self.router = router
		self.homeManager = managerProvider.homeManager
		super.init(managerProvider: managerProvider)
	}
	
	func saveAction(completion: @escaping () -> Void) {
		guard validateRoomName() else {
			completion()
			return
		}
		createHome(name: homeName.value.extraWhitespacesRemoved) {
			completion()
		}
	}
	
	private func createHome(name: String, completion: @escaping () -> Void) {
		homeManager.createHome(name: name, success: { [weak self] in
			guard let `self` = self else {
				completion()
				return
			}
			completion()
			self.router.enqueueRoute(with: CreateHomeRouter.RouteType.location)
		}) { _ in
			completion()
		}
	}
	
	private func validateRoomName() -> Bool {
		
		if homeName.value.extraWhitespacesRemoved.isEmpty {
			homeNameErrorMessage.value = "Home Name is not Empty"
			return false
		} else {
			homeNameErrorMessage.value = ""
			return true
		}
	}
	
}
