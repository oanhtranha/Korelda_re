//
//  WifiDetailViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 12/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol WifiDetailViewModelProtocol: BaseViewModelProtocol {
    var disableCloseButton: PublishSubject<Bool> { get }
    var ssidText: Variable<String> { get }
    var wifiPassText: Variable<String> { get }
    var ssidErrorMessage: Variable<String> { get }
    
    func setup()
    func saveWifiInfo(completion: @escaping () -> Void)
    func getTariffInfo(completion: @escaping () -> Void)
    
}

class WifiDetailViewModel: BaseViewModel, WifiDetailViewModelProtocol {
    let router: BaseRouterProtocol
    let disableCloseButton = PublishSubject<Bool>()
    let ssidText = Variable<String>("")
    let wifiPassText = Variable<String>("")
    let ssidErrorMessage =  Variable<String>("")
    
    private let settingManager: SettingManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance ) {
        self.router =  router
        self.settingManager = managerProvider.settingManager
        super.init(managerProvider: managerProvider)
    }
    
    func setup() {
        if UserDefaultsManager.loggedIn.enabled {
            guard let ssid = UserDefaultsManager.wifiSsid.value, let pass = UserDefaultsManager.wifiPass.value else {
                return
            }
            ssidText.value = ssid
            wifiPassText.value = pass
        } else {
            guard let wifiSsid = UserDataManager.shared.wifiInfo?.ssid else {
                return
            }
            ssidText.value = wifiSsid
        }
    }
    
	func saveWifiInfo(completion: @escaping () -> Void) {
        guard validateAll() else {
			completion()
            return
        }
        UserDefaultsManager.wifiSsid.value = ssidText.value.extraWhitespacesRemoved
        UserDefaultsManager.wifiPass.value = wifiPassText.value.extraWhitespacesRemoved
        if UserDefaultsManager.loggedIn.enabled {
            router.enqueueRoute(with: WifiDetailRouter.RouteType.back)
			completion()
        } else {
			getTariffInfo {
				completion()
			}
        }
    }
    
    func getTariffInfo(completion: @escaping () -> Void) {
        disableCloseButton.onNext(true)
        settingManager.getTariff(success: { [weak self] in
            self?.disableCloseButton.onNext(false)
            self?.showEnriffScreen()
			completion()
        }, failure: { [weak self] _ in
            self?.disableCloseButton.onNext(false)
            self?.showEnriffScreen()
			completion()
        })
    }
    
    private func validateAll() -> Bool {
        let validate = validateSsid()
        return validate
    }
    
    private func validateSsid() -> Bool {
        if ssidText.value.extraWhitespacesRemoved.isEmpty {
            ssidErrorMessage.value = "SSID_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        ssidErrorMessage.value = ""
        return true
    }
    
    private func showEnriffScreen() {
        router.enqueueRoute(with: WifiDetailRouter.RouteType.energyTariff)
    }
}

