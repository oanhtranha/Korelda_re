//
//  MenuSettingsViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 9/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SVProgressHUD
import CopilotAPIAccess

enum ConsumeType: Int {
    case Month = 0
    case Week = 1
    case Day = 2
    case Unknow
    
    init(from int: Int) {
           guard let value = ConsumeType(rawValue: int) else {
            self = .Unknow
               return
           }
           self = value
    }
}

protocol MenuSettingsViewModelProtocol: BaseViewModelProtocol {
    func logOut()
    var profileImage: Driver<UIImage?> { get }
    var settingItems: Variable<[SettingMenuItem]> { get }
    var userName: Variable<String> { get }
    var email: Variable<String> { get}
    var energyConsumed: Variable<String> { get}
    var timeTitle: Variable<String> { get}
    
    var currentTempUnit: Variable<TemperatureUnit> { get }
    var needUpdateAfterTempUnitChanged: PublishSubject<Bool> { get }
    var leaveHomeSubject: PublishSubject<Void> { get }
    
    func viewWillAppear()
    func selectedItem(at index: Int)
    func leaveHome(completion: @escaping (Bool) -> Void)
    func showConfigurationScreen(selectedRoom: Room)
    func showEneryConsume(of type: ConsumeType)
    func updateTempUnit(completion: @escaping () -> Void)
}

class MenuSettingsViewModel: BaseViewModel, MenuSettingsViewModelProtocol {
    
    var profileImage: Driver<UIImage?> { return profileImageSubject.asDriver(onErrorJustReturn: nil) }
    
    let settingItems = Variable<[SettingMenuItem]>([])
    let userName =  Variable<String>("")
    let email =  Variable<String>("")
    let energyConsumed = Variable<String>("$0.0")
    let timeTitle = Variable<String>("SPENT_TO_FAR_THIS_MONTH_TEXT".app_localized)
    
    let currentTempUnit = Variable<TemperatureUnit>(.C)
    let needUpdateAfterTempUnitChanged = PublishSubject<Bool>()
    let leaveHomeSubject = PublishSubject<Void>()
    private var profileImageSubject = BehaviorSubject<UIImage?>(value: UIImage(named: "defaultProfileImage"))
    
    let router: BaseRouterProtocol
    private let userManager: UserManager
    private let settingManager: SettingManager
    private var currentConsumeType: ConsumeType = .Month
	private var userType: UserType = .Undefine
    
    func viewWillAppear() {
        var menuList = SettingMenuItem.initSettingMenuItems()
		userType = UserType.init(fromString: UserDataManager.shared.currentUser?.userType ?? "")
		if userType == .Guest {
            menuList.append(SettingMenuItem(title: "LEAVE_SHARING_HOME_TEXT".app_localized, icon: UIImage(named: "ic-menu-multiple-user-access")))
		} else {
        menuList.append(SettingMenuItem(title: "SHARING_HOME_MANAGEMENT_TEXT".app_localized, icon: UIImage(named: "ic-menu-multiple-user-access")))
		}
        menuList.append(SettingMenuItem(title: "LEGAL_TEXT".app_localized, icon: UIImage(named: "ic-menu-legal")))
		settingItems.value = menuList
        currentTempUnit.value = UserDataManager.shared.temperatureUnit
        guard let name = UserDataManager.shared.currentUser?.name else {
            return
        }
        userName.value = name
        guard let emailOfUser = UserDataManager.shared.currentUser?.email else {
            return
        }
        email.value = emailOfUser
        getEnergyConsumedInfo()
		
    }
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router =  router
        settingManager =  managerProvider.settingManager
        userManager =  managerProvider.userManager
        super.init(managerProvider: managerProvider)
    }
    
    func logOut() {
        SVProgressHUD.show()
        userManager.logOut { [weak self] in
            SVProgressHUD.dismiss()
            Copilot.instance.report.log(event: LogoutAnalyticsEvent())
            self?.router.enqueueRoute(with: MenuSettingsRouter.RouteType.logOut)
        }
    }
    
    func selectedItem(at index: Int) {
        switch index {
        case 0:
            router.enqueueRoute(with: MenuSettingsRouter.RouteType.roomsConfiguration)
        case 1:
            router.enqueueRoute(with: MenuSettingsRouter.RouteType.addRoom)
        case 2:
            router.enqueueRoute(with: MenuSettingsRouter.RouteType.smartScheduling)
        case 3:
            router.enqueueRoute(with: MenuSettingsRouter.RouteType.updateTariff)
        case 4:
            router.enqueueRoute(with: MenuSettingsRouter.RouteType.wifiDetail)
        case 5:
            router.enqueueRoute(with: MenuSettingsRouter.RouteType.modifyModes)
		case 6:
			if userType == .Guest {
                log.info("Leave Sharing Home")
                leaveHomeSubject.onNext(())
			} else {
                log.info("Go Sharing Home Management")
                router.enqueueRoute(with: MenuSettingsRouter.RouteType.inviteFriendsDetail)
            }
        case 7:
            router.enqueueRoute(with: MenuSettingsRouter.RouteType.legal)
        default:
            break
        }
    }
    
    func leaveHome(completion: @escaping (Bool) -> Void) {
        userManager.leaveFromMasterHome(success: {
            completion(true)
        }) { error in
            completion(false)
        }
    }
    
    func showConfigurationScreen(selectedRoom: Room) {
        router.enqueueRoute(with: MenuSettingsRouter.RouteType.configuration(selectedRoom))
    }
    
    func showEneryConsume(of type: ConsumeType) {
        currentConsumeType = type
        let energyConsumedTariff = UserDataManager.shared.energyConsumed
        var amount: Double?
        switch type {
        case .Month:
            amount = energyConsumedTariff?.energyConsumedMonth
            break
        case .Week:
            amount = energyConsumedTariff?.energyConsumedWeek
            break
        case .Day:
            amount = energyConsumedTariff?.energyConsumedDay
            break
        case .Unknow:
            break
        }
        updateTimeTitle()
        guard let currencySymbol = UserDataManager.shared.tariff?.currency.kld_getCurrencySymbol(), let consumeValue = amount else {
            energyConsumed.value = "$0.0"
            return
        }
        energyConsumed.value = String(format: "%@%@", currencySymbol, consumeValue.currencyFormatter())
    }
    
    func updateTempUnit(completion: @escaping () -> Void) {
        let selectedUnit: TemperatureUnit = currentTempUnit.value == .C ? .F : .C
        settingManager.updateTemperatureUnit(temperatureUnit: selectedUnit.rawValue, success: { [weak self] in
            self?.currentTempUnit.value = selectedUnit
            UserDataManager.shared.temperatureUnit = selectedUnit
            self?.needUpdateAfterTempUnitChanged.onNext(true)
            completion()
        }) {  [weak self] _ in
            self?.needUpdateAfterTempUnitChanged.onNext(false)
            completion()
        }
    }
    
    private func updateTimeTitle() {
        switch currentConsumeType {
        case .Month:
            timeTitle.value = "SPENT_TO_FAR_THIS_MONTH_TEXT".app_localized
            break
        case .Week:
            timeTitle.value = "SPENT_TO_FAR_THIS_WEEK_TEXT".app_localized
            break
        case .Day:
            timeTitle.value = "SPENT_TO_FAR_THIS_DAY_TEXT".app_localized
            break
        case .Unknow:
            break
        }
        
    }
    
    private func getTariffInfo(completion: @escaping () -> Void) {
        settingManager.getTariff(success: {
            completion()
        }) { _ in
            completion()
        }
    }
    
    private func getEnergyConsumedInfo() {
        getTariffInfo { [weak self] in
            self?.settingManager.getEnergyConsumed(success: { [weak self] in
                guard let type = self?.currentConsumeType else { return }
                self?.showEneryConsume(of: type)
            }) { _ in
            }
        }
    }
}

struct SettingMenuItem {
    let title: String
    let icon: UIImage?
    
    init(title: String, icon: UIImage?) {
        self.title = title
        self.icon = icon
    }
    
    static func initSettingMenuItems() -> [SettingMenuItem] {
        var settingMenuItems: [SettingMenuItem] = []
        settingMenuItems.append(SettingMenuItem(title: "ROOM_CONFIGURATION_TEXT".app_localized, icon: UIImage(named: "ic-menu-room-setting")))
        settingMenuItems.append(SettingMenuItem(title: "ADD_ROOM_TEXT".app_localized, icon: UIImage(named: "ic-menu-add-room")))
        settingMenuItems.append(SettingMenuItem(title: "SMART_SCHEDULING_TEXT".app_localized, icon: UIImage(named: "ic-menu-smart-scheduling")))
        settingMenuItems.append(SettingMenuItem(title: "ENERGY_TARIFF_TEXT".app_localized, icon: UIImage(named: "ic-menu-energy-Tariff")))
        settingMenuItems.append(SettingMenuItem(title: "WIFI_SETTINGS_TEXT".app_localized, icon: UIImage(named: "ic-menu-wifi-setting")))
        settingMenuItems.append(SettingMenuItem(title: "MODITY_TEMPERATURE_MODES_TEXT".app_localized, icon: UIImage(named: "ic-menu-modify-temperature-modes")))
        return settingMenuItems
    }
}
