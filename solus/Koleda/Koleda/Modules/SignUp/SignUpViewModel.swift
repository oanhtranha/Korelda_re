//
//  SignUpViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 6/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CopilotAPIAccess

protocol SignUpViewModelProtocol: BaseViewModelProtocol {
    
    var fullName: Variable<String> { get }
    var email: Variable<String> { get }
    var password: Variable<String> { get }
    var showPassword: PublishSubject<Bool> { get }
    
    var fullNameErrorMessage: Variable<String> { get }
    var emailErrorMessage: Variable<String> { get }
    var passwordErrorMessage: Variable<String> { get }
    var showErrorMessage: PublishSubject<String> { get }
    
    

    func showPassword(isShow: Bool)
    func next(completion: @escaping (WSError?) -> Void)
    func loginAfterSignedUp(completion: @escaping (String) -> Void)
    func goTermAndConditions()
    func validateAll() -> Bool 
}

class SignUpViewModel: BaseViewModel, SignUpViewModelProtocol {
    
    
    let router: BaseRouterProtocol
    
    let fullName = Variable<String>("")
    let email = Variable<String>("")
    let password = Variable<String>("")
    let passwordConfirm = Variable<String>("")
    
    let showPassword = PublishSubject<Bool>()
    let showPasswordConfirm = PublishSubject<Bool>()
    
    let fullNameErrorMessage = Variable<String>("")
    let emailErrorMessage =  Variable<String>("")
    let passwordErrorMessage =  Variable<String>("")
    let passwordConfirmErrorMessage = Variable<String>("")
    let showErrorMessage = PublishSubject<String>()
    
    private let signUpManager: SignUpManager
    private let loginAppManager: LoginAppManager
    private let userManager: UserManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router = router
        self.loginAppManager = managerProvider.loginAppManager
        self.signUpManager =  managerProvider.signUpManager
        self.userManager = managerProvider.userManager
        super.init(managerProvider: managerProvider)
    }
    
    
    func showPassword(isShow: Bool) {
        self.showPassword.onNext(isShow)
    }
    
    func next(completion: @escaping (WSError?) -> Void) {
        let emailValue = email.value.extraWhitespacesRemoved
        let passwordValue = password.value.extraWhitespacesRemoved
        self.signUpManager.signUp(name: fullName.value.extraWhitespacesRemoved,
                                  email: emailValue,
                                  password: passwordValue,
                                  success: { [weak self] in
                                    Copilot.instance.report.log(event: SignupAnalyticsEvent())
                                    completion(nil)
            },
                                  failure: { error in
                                    completion(error as? WSError)
        })
    }
    
    func loginAfterSignedUp(completion: @escaping (String) -> Void) {
        let emailValue = email.value.extraWhitespacesRemoved
        let passwordValue = password.value.extraWhitespacesRemoved
        loginAppManager.login(email: emailValue, password: passwordValue, success: { [weak self] in
            self?.getCurrentUser { [weak self] in
                guard let userId = UserDataManager.shared.currentUser?.id else {
                    return
                }
                Copilot.instance
                    .manage
                    .yourOwn
                    .sessionStarted(withUserId: userId,
                                    isCopilotAnalysisConsentApproved: true)
                Copilot.instance.report.log(event: LoginAnalyticsEvent())
                completion("")
            }
        }, failure: { error in
            completion("LOGIN_FAILED_TRY_AGAIN_MESS".app_localized)
        })
    }
    
    func goTermAndConditions() {
        router.enqueueRoute(with: SignUpRouter.RouteType.termAndConditions)
    }
}

extension SignUpViewModel {
    
    private func getCurrentUser(completion: @escaping () -> Void) {
        userManager.getCurrentUser(success: {
            completion()
        }, failure: { error in
            completion()
        })
    }
    
    func validateAll() -> Bool {
        var failCount = 0
        failCount += validateFullName() ? 0 : 1
        failCount += validateEmail() ? 0 : 1
        failCount += validatePassword() ? 0 : 1
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
}
