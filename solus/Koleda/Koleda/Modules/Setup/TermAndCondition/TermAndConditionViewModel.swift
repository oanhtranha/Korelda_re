//
//  TermAndConditionViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 7/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD

enum LegalItem {
    case legalPrivacyPolicy
    case legalTermAndConditions
    case termAndConditions
}


protocol TermAndConditionViewModelProtocol: BaseViewModelProtocol {
    var legalItem: Variable<LegalItem>  { get }
    func showNextScreen()
}

class TermAndConditionViewModel: BaseViewModel, TermAndConditionViewModelProtocol {
    
    let router: BaseRouterProtocol
    private let justSignedUpNewAcc: Bool
	
    let legalItem = Variable<LegalItem>(.termAndConditions)
    
    init(router: BaseRouterProtocol, justSignedUpNewAcc: Bool = false, managerProvider: ManagerProvider = .sharedInstance, legalItem: LegalItem = .termAndConditions) {
        self.legalItem.value = legalItem
        self.router = router
		self.justSignedUpNewAcc = justSignedUpNewAcc
        super.init(managerProvider: managerProvider)
    }
    
    func showNextScreen() {
        if let user = UserDataManager.shared.currentUser, user.homes.count > 0 && !justSignedUpNewAcc {
            let userType = UserType.init(fromString: user.userType ?? "")
            if userType == .Master {
                UserDataManager.shared.stepProgressBar = StepProgressBar(total: 4)
                self.router.enqueueRoute(with: TermAndConditionRouter.RouteType.location)
            } else {
                UserDataManager.shared.stepProgressBar = StepProgressBar(total: 0)
                self.router.enqueueRoute(with: TermAndConditionRouter.RouteType.location)
            }
          
        } else {
            UserDataManager.shared.stepProgressBar = StepProgressBar(total: 5)
            self.router.enqueueRoute(with: TermAndConditionRouter.RouteType.createHome)
        }
    }
    
}
