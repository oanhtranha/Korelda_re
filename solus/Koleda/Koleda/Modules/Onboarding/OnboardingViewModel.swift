//
//  OnboardingViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit
import CopilotAPIAccess

enum SocialType: String {
    case facebook = "facebook"
    case google = "google"
	case apple = "apple"
}

protocol OnboardingViewModelProtocol: BaseViewModelProtocol {
    func prepare(for segue: UIStoryboardSegue)
    func startSignUpFlow()
    func startSignInFlow()
	func joinHome()
    func loginWithSocial(type: SocialType, accessToken: String, completion: @escaping (Bool, WSError?) -> Void)
}

class OnboardingViewModel: BaseViewModel, OnboardingViewModelProtocol {
    let router: BaseRouterProtocol
    private let loginAppManager: LoginAppManager
	private let userManager: UserManager
    
    init(with router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router = router
        self.loginAppManager = managerProvider.loginAppManager
		self.userManager = managerProvider.userManager
        super.init(managerProvider: managerProvider)
    }
    
    
    func prepare(for segue: UIStoryboardSegue) {
        router.prepare(for: segue)
    }
    
    func loginWithSocial(type: SocialType, accessToken: String, completion: @escaping (Bool, WSError?) -> Void) {
        loginAppManager.loginWithSocial(type: type, accessToken: accessToken, success: { [weak self] in
            log.info("User signed in successfully")
            guard let `self` = self else {
                return
            }
            self.processAfterLoginSuccessfull()
            Copilot.instance.report.log(event: LoginSocialAnalyticsEvent(provider: type.rawValue, token: accessToken, zoneId: TimeZone.current.identifier, screenName: self.screenName))
//            self?.router.enqueueRoute(with: OnboardingRouter.RouteType.termAndConditions)
            completion(true, nil)
        }, failure: { error in
            completion(false, error as? WSError)
        })
    }
    
    func startSignUpFlow() {
        router.enqueueRoute(with: OnboardingRouter.RouteType.signUp)
    }
    
    func startSignInFlow() {
        router.enqueueRoute(with: OnboardingRouter.RouteType.logIn)
    }
	
	func joinHome() {
		router.enqueueRoute(with: OnboardingRouter.RouteType.joinHome)
	}
	
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
				self?.router.enqueueRoute(with: OnboardingRouter.RouteType.termAndConditions)
				return
			}
			
			if showTermAndCondition {
				self?.router.enqueueRoute(with: OnboardingRouter.RouteType.termAndConditions)
			} else {
				self?.router.enqueueRoute(with: OnboardingRouter.RouteType.home)
				UserDefaultsManager.loggedIn.enabled = true
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
}
