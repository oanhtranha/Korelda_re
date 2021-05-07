//
//  LoginViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 6/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import CopilotAPIAccess



protocol LoginViewModelProtocol: BaseViewModelProtocol {
    
    var email: Variable<String> { get }
    var password: Variable<String> { get }
    var emailErrorMessage: Variable<String> { get }
    var passwordErrorMessage: Variable<String> { get }
    
    var showPassword: Variable<Bool> { get }
    
    func viewWillAppear()
    func login(completion: @escaping (Bool) -> Void)
    func showPassword(isShow: Bool)
    func prepare(for segue: UIStoryboardSegue)
    func backOnboardingScreen()
    func forgotPassword()
    func loginWithSocial(type: SocialType, accessToken: String, completion: @escaping (Bool, WSError?) -> Void)
}

class LoginViewModel: BaseViewModel, LoginViewModelProtocol {
    var email = Variable<String>("")
    let password = Variable<String>("")
    let emailErrorMessage = Variable<String>("")
    let passwordErrorMessage = Variable<String>("")
    
    let showPassword = Variable<Bool>(false)
    
    
    let router: BaseRouterProtocol
    
    private var _isShowPass = BehaviorSubject(value: false)
    
    private let loginAppManager: LoginAppManager
	private let userManager: UserManager
    private var disposeBag = DisposeBag()
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router = router
        loginAppManager = managerProvider.loginAppManager
		userManager = managerProvider.userManager
        super.init(managerProvider: managerProvider)
    }
    
    func viewWillAppear() {
        guard let lastestEmaillogined = UserDefaultsManager.termAndConditionAcceptedUser.value?.extraWhitespacesRemoved else {
            return
        }
        email.value = lastestEmaillogined
    }
    
    func forgotPassword() {
        router.enqueueRoute(with: LoginRouter.RouteType.forgotPassword)
    }
    
    func showPassword(isShow: Bool) {
        showPassword.value = isShow
    }
    
    func login(completion: @escaping (Bool) -> Void) {
        guard validateAll() else {
            completion(true)
            return
        }
        
        loginAppManager.login(email: email.value.extraWhitespacesRemoved,
                              password: password.value.extraWhitespacesRemoved,
                              success: { [weak self] in
								log.info("User signed in successfully")
                                self?.processAfterLoginSuccessfull()
                                Copilot.instance.report.log(event: LoginAnalyticsEvent())
                                completion(true)
            },
                              failure: { error in
                                completion(false)
        })
    }
    
    func prepare(for segue: UIStoryboardSegue) {
        router.prepare(for: segue)
    }
    
    func backOnboardingScreen() {
        router.enqueueRoute(with: LoginRouter.RouteType.onboaring)
    }
    
    func loginWithSocial(type: SocialType, accessToken: String, completion: @escaping (Bool, WSError?) -> Void) {
        loginAppManager.loginWithSocial(type: type, accessToken: accessToken,
        success: { [weak self] in
            log.info("User signed in successfully")
            guard let `self` = self else {
                return
            }
            Copilot.instance.report.log(event: LoginSocialAnalyticsEvent(provider: type.rawValue, token: accessToken, zoneId: TimeZone.current.identifier, screenName: self.screenName))
			self.processAfterLoginSuccessfull()
            completion(true, nil)
        }, failure: { error in
            completion(false, error as? WSError)
        })
    }
	
}


extension LoginViewModel {
    
    private func processAfterLoginSuccessfull() {
		var showTermAndCondition: Bool = true
		
		getCurrentUser { [weak self] in
            guard let userId = UserDataManager.shared.currentUser?.id else {
                return
            }
            Copilot.instance
                .manage
                .yourOwn
                .sessionStarted(withUserId: userId,
                                isCopilotAnalysisConsentApproved: true)
			if let termAndConditionAcceptedUser = UserDefaultsManager.termAndConditionAcceptedUser.value?.extraWhitespacesRemoved, termAndConditionAcceptedUser == UserDataManager.shared.currentUser?.email  {
				showTermAndCondition = false
			}
			
			// If User hasn't created a home yet
			guard let user = UserDataManager.shared.currentUser, user.homes.count > 0 else {
				self?.router.enqueueRoute(with: LoginRouter.RouteType.termAndConditions)
				return
			}
			
			if showTermAndCondition {
				self?.router.enqueueRoute(with: LoginRouter.RouteType.termAndConditions)
			} else {
				UserDefaultsManager.loggedIn.enabled = true
				self?.router.enqueueRoute(with: LoginRouter.RouteType.home)
			}
		}
    }
    
	private func getCurrentUser(completion: @escaping () -> Void) {
		userManager.getCurrentUser(success: {
			completion()
		}, failure: { error in
			completion()
		})
	}
	
    private func validateAll() -> Bool {
        var failCount = 0
        failCount += validateEmail() ? 0 : 1
        failCount += validatePassword() ? 0 : 1
        return failCount == 0
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
            emailErrorMessage.value = "EMAIL_INVALID_MESSAGE".app_localized
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
}
