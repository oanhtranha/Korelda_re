
//
//  TemperatureUnitViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 9/17/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol TemperatureUnitViewModelProtocol: BaseViewModelProtocol {
    func viewWillAppear()
    func confirmedAndFinished()
    func updateUnit(selectedUnit: TemperatureUnit)
    var seletedUnit: Variable<TemperatureUnit> { get }
    var hasChanged: PublishSubject<Bool> { get }
}

class TemperatureUnitViewModel: BaseViewModel, TemperatureUnitViewModelProtocol {
   
    let router: BaseRouterProtocol
    let seletedUnit = Variable<TemperatureUnit>(.C)
    var hasChanged = PublishSubject<Bool>()
    private var lastestUnit: TemperatureUnit = UserDataManager.shared.temperatureUnit
    private let settingManager: SettingManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router = router
        self.settingManager = managerProvider.settingManager
        super.init(managerProvider: managerProvider)
    }
    
    func viewWillAppear() {
        seletedUnit.value = lastestUnit
    }
    
    func confirmedAndFinished() {
        let selectedUnit = seletedUnit.value
        if lastestUnit != selectedUnit {
            settingManager.updateTemperatureUnit(temperatureUnit: selectedUnit.rawValue, success: { [weak self] in
                UserDataManager.shared.temperatureUnit = selectedUnit
                self?.hasChanged.onNext(true)
                self?.goHome()
            }) {  [weak self] _ in
                self?.hasChanged.onNext(false)
            }
        } else {
            goHome()
        }
    }
    
    func updateUnit(selectedUnit: TemperatureUnit) {
        lastestUnit = self.seletedUnit.value
        self.seletedUnit.value = selectedUnit
    }
    
    private func goHome() {
        if UserDataManager.shared.stepProgressBar.totalStep == 5 {
            router.enqueueRoute(with: TemperatureUnitRouter.RouteType.inviteFriends)
        } else {
            UserDefaultsManager.loggedIn.enabled = true
            router.enqueueRoute(with: TemperatureUnitRouter.RouteType.home)
        }
    }
}
