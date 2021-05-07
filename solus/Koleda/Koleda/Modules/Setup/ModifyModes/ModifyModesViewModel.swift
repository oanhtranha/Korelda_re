
//
//  ModifyModesViewModel.swift
//  Koleda
//
//  Created by Oanh Tran on 2/3/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol ModifyModesViewModelProtocol: BaseViewModelProtocol {
    var smartModes: Variable<[ModeItem]>  { get }
    func didSelectMode(atIndex: Int)
    func loadModes()
}

class ModifyModesViewModel: BaseViewModel, ModifyModesViewModelProtocol {
    
    let router: BaseRouterProtocol
    private let settingManager: SettingManager
    let smartModes = Variable<[ModeItem]>([])
    
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router =  router
        settingManager =  managerProvider.settingManager
        super.init(managerProvider: managerProvider)
        loadModes()
    }
    
    func loadModes() {
        smartModes.value = UserDataManager.shared.settingModesWithoutDefaultMode()
    }
    
    func didSelectMode(atIndex: Int) {
        let selectedMode = smartModes.value[atIndex]
        showDetailMode(selectedMode: selectedMode)
    }
    
    private func showDetailMode(selectedMode: ModeItem) {
        router.enqueueRoute(with: ModifyModesRouter.RouteType.detailMode(selectedMode))
    }
}
