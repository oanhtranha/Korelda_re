//
//  DetailModeViewMode.swift
//  Koleda
//
//  Created by Oanh Tran on 2/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol DetailModeViewModelProtocol: BaseViewModelProtocol {
    var selectedMode: Variable<ModeItem?> { set get }
    var tempList: [Int] { set get}
    var currentTemperature: Int { set get }
    var reloadCollectionView: PublishSubject<Void> { get set}
    var showErrorMessage: PublishSubject<String> { get set }
    
    func didSelectedTemperature(temp: Int)
    func confirmed()
    func backToModifyModes()
}

class DetailModeViewModel: BaseViewModel, DetailModeViewModelProtocol {
    
    let router: BaseRouterProtocol
    var selectedMode = Variable<ModeItem?>(nil)
    var tempList: [Int] = []
    var currentTemperature: Int = 0
    var reloadCollectionView = PublishSubject<Void>()
    var showErrorMessage = PublishSubject<String>()
    
    private let settingManager: SettingManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, selectedMode: ModeItem) {
        self.router =  router
        settingManager =  managerProvider.settingManager
        super.init(managerProvider: managerProvider)
        self.setup()
        self.selectedMode.value = selectedMode
    }
    
    private func setup() {
        let minTemp = Constants.MIN_TEMPERATURE.integerPart()
        let maxTemp = Constants.MAX_TEMPERATURE.integerPart()
        for i in (minTemp...maxTemp) {
            tempList.append(i)
        }
        reloadCollectionView.onNext(())
    }
    
    func didSelectedTemperature(temp: Int) {
        self.currentTemperature = temp
        reloadCollectionView.onNext(())
    }
    
    func confirmed() {
        guard let modeName = selectedMode.value?.mode.rawValue else { return }
        let newTempMode = Double(currentTemperature)
        let currentTempMode = selectedMode.value?.temperature
        if newTempMode != currentTempMode {
            settingManager.updateTempMode(modeName: modeName, temp: newTempMode, success: { [weak self] in
                NotificationCenter.default.post(name: .KLDDidUpdateTemperatureModes, object: nil)
                self?.backToModifyModes()
            }) {  [weak self] _ in
                self?.showErrorMessage.onNext("Can't Update Temperature of Mode now")
            }
        } else {
            backToModifyModes()
        }
    }
    
    func backToModifyModes() {
        router.enqueueRoute(with: DetailModeRouter.RouteType.backModifyModes)
    }
    
}


