//
//  ForgotPasswordViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 6/20/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import CopilotAPIAccess

protocol ForgotPassWordViewModelProtocol: BaseViewModelProtocol {
    
    var email: Variable<String> { get }
    var emailErrorMessage: PublishSubject<String> { get }
    func getNewPassword(completion: @escaping (Bool, String) -> Void)
}

class ForgotPasswordViewModel: BaseViewModel, ForgotPassWordViewModelProtocol {
    var router: BaseRouterProtocol
    
    let email = Variable<String>("")
    let emailErrorMessage = PublishSubject<String>()
    private let signUpManager: SignUpManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router = router
        self.signUpManager =  managerProvider.signUpManager
        super.init(managerProvider: managerProvider)
    }
    
    func getNewPassword(completion: @escaping (Bool, String) -> Void) {
        
        guard validateEmail() else {
            completion(false, "")
            return
        }
        let emailReset = email.value.extraWhitespacesRemoved
        signUpManager.resetPassword(email: emailReset,
        success: {
            completion(true, "")
            Copilot.instance.report.log(event: ForgotPasswordAnalyticsEvent(email: emailReset, screenName: self.screenName))
        },
        failure: { error in
            var errorMessage: String = error.localizedDescription
            if let wsError = error as? WSError, wsError == WSError.userNotFound {
                errorMessage = String(format: "%@ %@", wsError.localizedDescription.app_localized, emailReset)
            }
            completion(false, errorMessage)
        })
    }
}

extension ForgotPasswordViewModel {
    private func validateEmail() -> Bool {
        if email.value.extraWhitespacesRemoved.isEmpty {
            emailErrorMessage.onNext("EMAIL_IS_NOT_EMPTY_MESS".app_localized)
            return false
        }
        if DataValidator.isEmailValid(email: email.value.extraWhitespacesRemoved) {
            emailErrorMessage.onNext("")
            return true
        } else {
            emailErrorMessage.onNext("EMAIL_IS_INVALID_MESS".app_localized)
            return false
        }
    }
}
