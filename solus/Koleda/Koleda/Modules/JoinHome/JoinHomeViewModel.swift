//
//  JoinHomeViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 6/24/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import RxSwift
import CopilotAPIAccess

protocol JoinHomeViewModelProtocol: BaseViewModelProtocol {
	
    var fullName: Variable<String> { get }
    var email: Variable<String> { get }
    var password: Variable<String> { get }
    var homeID: Variable<String> { get }
    
    var showPassword: PublishSubject<Bool> { get }
    
    var fullNameErrorMessage: Variable<String> { get }
    var emailErrorMessage: Variable<String> { get }
    var passwordErrorMessage: Variable<String> { get }
    var homeIDErrorMessage: Variable<String> { get }
    var showErrorMessage: PublishSubject<String> { get }
    
    func validateAll() -> Bool
    func next(completion: @escaping (WSError?) -> Void)
    func loginAfterJoinHome(completion: @escaping (String) -> Void)
    func showPassword(isShow: Bool)
}
class JoinHomeViewModel: BaseViewModel, JoinHomeViewModelProtocol {
	
    let fullName = Variable<String>("")
    let email = Variable<String>("")
    let password = Variable<String>("")
    let homeID = Variable<String>("")
    
    let showPassword = PublishSubject<Bool>()
    
    let fullNameErrorMessage = Variable<String>("")
    let emailErrorMessage =  Variable<String>("")
    let passwordErrorMessage =  Variable<String>("")
    let homeIDErrorMessage = Variable<String>("")
    let showErrorMessage = PublishSubject<String>()
    
	let router: BaseRouterProtocol
    private let userManager: UserManager
    private let loginAppManager: LoginAppManager
	
	init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
		self.router = router
        self.userManager = managerProvider.userManager
        self.loginAppManager = managerProvider.loginAppManager
		super.init(managerProvider: managerProvider)
	}
    
    func showPassword(isShow: Bool) {
         self.showPassword.onNext(isShow)
    }
    
    func next(completion: @escaping (WSError?) -> Void) {
        let nameValue = fullName.value.extraWhitespacesRemoved
        let emailValue = email.value.extraWhitespacesRemoved
        let passwordValue = password.value.extraWhitespacesRemoved
        let homeId = homeID.value.extraWhitespacesRemoved
        
        self.userManager.joinHome(name: nameValue, email: emailValue, password: passwordValue, homeId: homeId, success: {
            Copilot.instance.report.log(event: JoinHomeAnalyticsEvent(name: nameValue, email: emailValue, homeId: homeId, screenName: self.screenName))
            completion(nil)
        }, failure: { error in
            completion(error as? WSError)
        })
        
    }
    
    func loginAfterJoinHome(completion: @escaping (String) -> Void) {
        let emailValue = email.value.extraWhitespacesRemoved
        let passwordValue = password.value.extraWhitespacesRemoved
        loginAppManager.login(email: emailValue, password: passwordValue, success: { [weak self] in
            self?.processAfterLoginSuccessfull()
            Copilot.instance.report.log(event: LoginAnalyticsEvent())
            completion("")
        }, failure: { error in
            completion("LOGIN_FAILED_TRY_AGAIN_MESS".app_localized)
        })
    }
    
    private func processAfterLoginSuccessfull() {
        getCurrentUser { [weak self] in
            self?.router.enqueueRoute(with: JoinHomeRouter.RouteType.termAndConditions)
        }
    }
    
    private func getCurrentUser(completion: @escaping () -> Void) {
        userManager.getCurrentUser(success: {
            guard let userId = UserDataManager.shared.currentUser?.id else {
                return
            }
            Copilot.instance
                .manage
                .yourOwn
                .sessionStarted(withUserId: userId,
                                isCopilotAnalysisConsentApproved: true)
            completion()
        }, failure: { error in
            completion()
        })
    }
}

extension JoinHomeViewModel {
    
    func validateAll() -> Bool {
        var failCount = 0
        failCount += validateFullName() ? 0 : 1
        failCount += validateEmail() ? 0 : 1
        failCount += validatePassword() ? 0 : 1
        failCount += validateHomeID() ? 0 : 1
        return failCount == 0
    }
    
    private func validateFullName() -> Bool {
        let normalizedFullName = fullName.value.extraWhitespacesRemoved
        if normalizedFullName.isEmpty {
            fullNameErrorMessage.value = "NAME_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        
        if DataValidator.isValid(fullName: normalizedFullName) && normalizedFullName.count >= 2 && normalizedFullName.count <= 50 {
            fullNameErrorMessage.value = ""
            return true
        } else {
            fullNameErrorMessage.value = "NAME_IS_INVALID_MESS".app_localized
            return false
        }
    }
    
    private func validateEmail() -> Bool {
        if email.value.extraWhitespacesRemoved.isEmpty {
            emailErrorMessage.value = "EMAIL_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        
        if DataValidator.isEmailValid(email: email.value.extraWhitespacesRemoved) {
            emailErrorMessage.value = ""
            return true
        } else {
            emailErrorMessage.value = "EMAIL_IS_INVALID_MESS".app_localized
            return false
        }
    }
    
    private func validatePassword() -> Bool {
        if password.value.extraWhitespacesRemoved.isEmpty {
            passwordErrorMessage.value = "PASS_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        
        if DataValidator.isEmailPassword(pass: password.value.extraWhitespacesRemoved)
        {
            passwordErrorMessage.value = ""
            return true
        } else {
            passwordErrorMessage.value = "INVALID_PASSWORD_MESSAGE".app_localized
            return false
        }
    }
    
    private func validateHomeID() -> Bool {
        if homeID.value.extraWhitespacesRemoved.isEmpty {
            homeIDErrorMessage.value = "HOME_ID_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        
        if homeID.value.extraWhitespacesRemoved.count > 5
        {
            homeIDErrorMessage.value = ""
            return true
        } else {
            homeIDErrorMessage.value = "HOME_ID_IS_INVALID_MESS".app_localized
            return false
        }
    }
}

