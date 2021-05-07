//
//  WelcomeJoinHomeViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 8/5/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation

protocol WelcomeJoinHomeViewModelProtocol: BaseViewModelProtocol {
    func goHome()
}

class WelcomeJoinHomeViewModel: BaseViewModel, WelcomeJoinHomeViewModelProtocol {
    let router: BaseRouterProtocol
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router = router
        super.init(managerProvider: managerProvider)
    }
    
    func goHome() {
        UserDefaultsManager.loggedIn.enabled = true
        router.enqueueRoute(with: WelcomeJoinHomeRouter.RouteType.home)
    }
}
