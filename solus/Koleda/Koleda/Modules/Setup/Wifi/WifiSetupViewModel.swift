//
//  WifiSetupViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 7/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import SVProgressHUD

protocol WifiSetupViewModelProtocol: BaseViewModelProtocol {

    var showRetryButton: Variable<Bool> { get }
    var disableCloseButton: PublishSubject<Bool> { get }
    
    func checkWifiConnection()
    func showWifiDetailScreen()
}

class WifiSetupViewModel: BaseViewModel, WifiSetupViewModelProtocol {
    let router: BaseRouterProtocol
    let showRetryButton = Variable<Bool>(false)
    let disableCloseButton = PublishSubject<Bool>()
    private let settingManager: SettingManager
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance ) {
        self.router =  router
        self.settingManager = managerProvider.settingManager
        super.init(managerProvider: managerProvider)
    }
    
    func checkWifiConnection() {
        self.showRetryButton.value = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let networkManager = NetworkManager()
            if networkManager.Connection() && networkManager.isWifi() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showWifiDetailScreen()
                }
            } else {
                self.showRetryButton.value = true
            }
        }
    }
    
    func showWifiDetailScreen() {
        router.enqueueRoute(with: WifiSetupRouter.RouteType.wifiDetail)
    }
}

