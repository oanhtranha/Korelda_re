//
//  EnergyTariffViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 7/31/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol EnergyTariffViewModelProtocol: BaseViewModelProtocol {
    var startOfDay: Variable<String> { get }
    var endOfDay: Variable<String> { get }
    var tariffOfDay: Variable<String> { get }
    var startOfNight: Variable<String> { get }
    var endOfNight: Variable<String> { get }
    var tariffOfNight: Variable<String> { get }
    var errorMessage: Variable<String> { get }
    var updateFinished: PublishSubject<Bool> { get }
    var currency: Variable<String> { get }
    
    func updatetTariffOfDay(amount: String)
    func updatetTariffOfNight(amount: String)
    func showNextScreen()
    func next(completion: @escaping () -> Void)
}

class EnergyTariffViewModel: BaseViewModel, EnergyTariffViewModelProtocol {
    
    let router: BaseRouterProtocol
    
    let startOfDay = Variable<String>("")
    let endOfDay = Variable<String>("")
    let tariffOfDay = Variable<String>("0.00")
    let startOfNight = Variable<String>("")
    let endOfNight = Variable<String>("")
    let tariffOfNight = Variable<String>("0.00")
    let currency = Variable<String>("")
    
    let errorMessage = Variable<String>("")
    let updateFinished = PublishSubject<Bool>()
    
    private let settingManager: SettingManager
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance ) {
        self.router =  router
        settingManager =  managerProvider.settingManager
        super.init(managerProvider: managerProvider)
        getTariffInfo()
    }
    
    func showNextScreen() {
        if UserDefaultsManager.loggedIn.enabled {
            router.enqueueRoute(with: EnergyTariffRouter.RouteType.backHome)
        } else {
            router.enqueueRoute(with: EnergyTariffRouter.RouteType.temperatureUnit)
        }
    }
    
    func next(completion: @escaping () -> Void) {
        if validateAll() {
            let tariffDay = (tariffOfDay.value as NSString).doubleValue
            let tariffNight = (tariffOfNight.value as NSString).doubleValue
            guard tariffDay > 0 && tariffNight > 0  else {
                completion()
                return
            }
            let tariff = Tariff(dayTimeStart: startOfDay.value,
                                dayTimeEnd: endOfDay.value,
                                dayTariff: tariffDay,
                                nightTimeStart: startOfNight.value,
                                nightTimeEnd: endOfNight.value,
                                nightTariff: tariffNight,
                                currency: currency.value)
            settingManager.updateTariff(tariff: tariff, success: { [weak self] in
                UserDataManager.shared.tariff = tariff
                self?.updateFinished.onNext(true)
                completion()
            },
            failure: { error in
                self.updateFinished.onNext(false)
                completion()
            })
        } else {
            completion()
            showNextScreen()
        }
    }
    
    private func getTariffInfo() {
        settingManager.getTariff(success: { [weak self] in
            self?.setupTariffInfo()
        }) { _ in
        }
    }
    
    private func setupTariffInfo() {
        guard let tariff = UserDataManager.shared.tariff else {
            return
        }
        startOfDay.value = tariff.dayTimeStart
        endOfDay.value = tariff.dayTimeEnd
        tariffOfDay.value = tariff.dayTariff != 0 ? "\(tariff.dayTariff)" : "0.00"
        startOfNight.value = tariff.nightTimeStart
        endOfNight.value = tariff.nightTimeEnd
        tariffOfNight.value = tariff.nightTariff != 0 ? "\(tariff.nightTariff)": "0.00"
        currency.value = tariff.currency
    }
    
    func updatetTariffOfDay(amount: String) {
        tariffOfDay.value = amount
    }
    func updatetTariffOfNight(amount: String) {
        tariffOfNight.value = amount
    }
    
    
    func validateAll() -> Bool {
        guard startOfDay.value.extraWhitespacesRemoved != "" else {
            errorMessage.value = "START_DAYTIME_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        guard endOfDay.value.extraWhitespacesRemoved != "" else {
            errorMessage.value = "END_DAYTIME_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        guard tariffOfDay.value.kld_doubleValue ?? 0.0 > 0.0 else {
            errorMessage.value = "TARIFF_NUMBER_IS_NOT_EMPTY".app_localized
            return false
        }
        guard startOfNight.value.extraWhitespacesRemoved != "" else {
            errorMessage.value = "START_NIGHTTIME_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        guard endOfNight.value.extraWhitespacesRemoved != "" else {
            errorMessage.value = "END_NIGHTTIME_IS_NOT_EMPTY_MESS".app_localized
            return false
        }
        guard tariffOfNight.value.kld_doubleValue ?? 0.0 > 0.0 else {
            errorMessage.value = "TARIFF_NUMBER_NIGHT_IS_NOT_EMPTY".app_localized
            return false
        }
        guard currency.value.extraWhitespacesRemoved != "" else {
            errorMessage.value = "CURRENCY_IS_NOT_EMPTY".app_localized
            return false
        }
        errorMessage.value = ""
        return tariffInfoChanged()
    }
    
    private func tariffInfoChanged() -> Bool {
        if let tariff = UserDataManager.shared.tariff  {
            let updated = (tariff.dayTimeStart != startOfDay.value.extraWhitespacesRemoved) ||
                (tariff.dayTimeEnd != endOfDay.value.extraWhitespacesRemoved) ||
                (tariff.nightTimeStart != startOfNight.value.extraWhitespacesRemoved) ||
                (tariff.nightTimeEnd != endOfNight.value.extraWhitespacesRemoved) ||
                ("\(tariff.dayTariff)" != tariffOfDay.value.extraWhitespacesRemoved) ||
                ("\(tariff.nightTariff)" != tariffOfNight.value.extraWhitespacesRemoved) ||
                tariff.currency != currency.value
            return updated
        } else {
            return true
        }
    }
}
