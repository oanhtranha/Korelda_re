//
//  InviteFriendsDetailViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 6/23/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol InviteFriendsDetailViewControllerProtocol: BaseViewModelProtocol {
    
    var emailText: Variable<String> { get }
    var emailErrorMessage: Variable<String> { get }
    var fiendsEmailList: Variable<[String]> { get }
    var showErrorMessage: PublishSubject<String> { get }
    
	func showInviteFriendsFinished()
    func invitedAFriend(completion: @escaping (Bool, WSError?) -> Void)
    func removeFriendBy(email: String, completion: @escaping () -> Void)
}

class InviteFriendsDetailViewModel: BaseViewModel, InviteFriendsDetailViewControllerProtocol {
    var emailText = Variable<String>("")
    let emailErrorMessage = Variable<String>("")
    let fiendsEmailList = Variable<[String]>([])
    
    let showErrorMessage = PublishSubject<String>()
	let router: BaseRouterProtocol
    private let userManager: UserManager
	
	init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
		self.router = router
        self.userManager = managerProvider.userManager
        super.init(managerProvider: managerProvider)
        self.getFriendsList {}
	}
	
    func invitedAFriend(completion: @escaping (Bool, WSError?) -> Void) {
        if validateEmail() {
            invitedFriend { [weak self] error in
                if error == nil {
                    self?.getFriendsList {
                        completion(true, nil)
                    }
                } else {
                    completion(false, error)
                }
            }
        } else {
            completion(false, nil)
        }
    }
    
    
	func showInviteFriendsFinished() {
		router.enqueueRoute(with: InviteFriendsDetailRouter.RouteType.invited)
	}
	
    private func invitedFriend(completion: @escaping (WSError?) -> Void) {
        let email = emailText.value.extraWhitespacesRemoved
        userManager.inviteFriend(email: email, success: {
            completion(nil)
        }) { [weak self] error in
            completion(error as? WSError)
        }
    }
    
    private func getFriendsList(completion: @escaping () -> Void) {
        userManager.getFriendsList(success: { [weak self] in
            self?.fiendsEmailList.value = UserDataManager.shared.friendsList
            completion()
        }) { [weak self] error in
            self?.showErrorMessage.onNext(("Can't get Friends List"))
            completion()
        }
    }
    
    private func validateEmail() -> Bool {
        if emailText.value.extraWhitespacesRemoved.isEmpty {
            emailErrorMessage.value = "Email is not Empty"
            return false
        }
        if DataValidator.isEmailValid(email: emailText.value.extraWhitespacesRemoved) {
            emailErrorMessage.value = ""
            return true
        } else {
            emailErrorMessage.value = "Email is invalid"
            return false
        }
    }
    
    func removeFriendBy(email: String, completion: @escaping () -> Void) {
        userManager.removeFriend(friendEmail: email, success: { [weak self] in
            self?.getFriendsList {
                completion()
            }
        }) {[weak self] error in
            self?.showErrorMessage.onNext(("Can't get Friends List"))
            completion()
        }
    }
}
