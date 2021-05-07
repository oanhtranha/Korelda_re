//
//  LegalViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 11/8/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol LegalViewModelProtocol: BaseViewModelProtocol {
    var legalItems: Variable<[String]> { get }
    func viewWillAppear()
    func selectedItem(index: Int)
}

class LegalViewModel: BaseViewModel, LegalViewModelProtocol {
    
    let legalItems = Variable<[String]>([])
    
    let router: BaseRouterProtocol
    private let settingManager: SettingManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance ) {
        self.router =  router
        self.settingManager = managerProvider.settingManager
        super.init(managerProvider: managerProvider)
    }
    
    func viewWillAppear() {
        var menuList: [String] = []
        menuList.append("PRIVACY_POLICY_TEXT".app_localized)
        menuList.append("TERMS_AND_CONDITIONS_TEXT".app_localized)
        legalItems.value = menuList
    }
    
    func selectedItem(index: Int) {
        switch index {
        case 0:
            router.enqueueRoute(with: LegalRouter.RouteType.privacyPolicy)
        case 1:
            router.enqueueRoute(with: LegalRouter.RouteType.termAndCondition)
        default:
            break
        }
    }
    
}

