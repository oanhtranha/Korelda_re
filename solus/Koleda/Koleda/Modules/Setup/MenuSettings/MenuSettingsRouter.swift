//
//  MenuSettingsRouter.swift
//  Koleda
//
//  Created by Oanh tran on 9/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class MenuSettingsRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case backHome
        case logOut
        case roomsConfiguration
        case addRoom
        case smartScheduling
        case updateTariff
        case configuration(Room)
        case wifiDetail
        case modifyModes
        case inviteFriendsDetail
        case legal
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func enqueueRoute(with context: Any?, animated: Bool, completion: ((Bool) -> Void)?) {
        guard let routeType = context as? RouteType else {
            assertionFailure("The route type missmatches")
            return
        }
        
        guard let baseViewController = baseViewController else {
            assertionFailure("baseViewController is not set")
            return
        }
        
        switch routeType {
        case .backHome:
            baseViewController.navigationController?.popToRootViewController(animated: false)
        case .logOut:

                let router = LoginRouter()
                guard let viewController = StoryboardScene.Login.initialViewController() as? LoginViewController else { return }
                let viewModel = LoginViewModel.init(router: router)
                viewController.viewModel = viewModel
                router.baseViewController = viewController
                let navigationController = UINavigationController(rootViewController: viewController)
                if let delegate = UIApplication.shared.delegate as? AppDelegate {
                    delegate.window?.rootViewController = navigationController
                }
        case .roomsConfiguration:
            baseViewController.gotoBlock(withStoryboar: "Home", aClass: ListRoomViewController.self) { (vc) in
                let router = HomeRouter()
                let viewModel = HomeViewModel.init(router: router)
                vc?.viewModel = viewModel
                router.baseViewController = vc
            }
        case .addRoom:
            let router = RoomDetailRouter()
            let viewModel = RoomDetailViewModel.init(router: router)
            guard let viewController = StoryboardScene.Room.instantiateRoomDetailViewController() as? RoomDetailViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .smartScheduling:
            let router = SmartSchedulingRouter()
            let viewModel = SmartSchedulingViewModel.init(router: router)
            guard let viewController = StoryboardScene.SmartSchedule.instantiateSmartSchedulingViewController() as? SmartSchedulingViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .updateTariff:
            let router = EnergyTariffRouter()
            let viewModel = EnergyTariffViewModel.init(router: router)
            guard let energyTariffVC = StoryboardScene.Setup.instantiateEnergyTariffViewController() as? EnergyTariffViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            energyTariffVC.viewModel = viewModel
            router.baseViewController = energyTariffVC
            baseViewController.navigationController?.pushViewController(energyTariffVC, animated: true)
        case .configuration(let selectedRoom):
            let router = ConfigurationRoomRouter()
            let viewModel = ConfigurationRoomViewModel.init(router: router, seletedRoom: selectedRoom)
            guard let viewController = StoryboardScene.Home.instantiateConfigurationRoomViewController() as? ConfigurationRoomViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .wifiDetail:
            let router = WifiDetailRouter()
            let viewModel = WifiDetailViewModel.init(router: router)
            guard let wifiDetailVC = StoryboardScene.Setup.instantiateWifiDetailViewController() as? WifiDetailViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            wifiDetailVC.viewModel = viewModel
            router.baseViewController = wifiDetailVC
            baseViewController.navigationController?.pushViewController(wifiDetailVC, animated: true)
        case .modifyModes:
            let router = ModifyModesRouter()
            let viewModel = ModifyModesViewModel.init(router: router)
            guard let modifyModesVC = StoryboardScene.Setup.instantiateModifyModesViewController() as? ModifyModesViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            modifyModesVC.viewModel = viewModel
            router.baseViewController = modifyModesVC
            baseViewController.navigationController?.pushViewController(modifyModesVC, animated: true)
        case .inviteFriendsDetail:
            let router = InviteFriendsDetailRouter()
            let viewModel =  InviteFriendsDetailViewModel.init(router: router)
            
            guard let viewController = StoryboardScene.Setup.instantiateInviteFriendsDetailViewController() as? InviteFriendsDetailViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .legal:
            let router = LegalRouter()
            let viewModel =  LegalViewModel.init(router: router)
            
            guard let viewController = StoryboardScene.Setup.instantiateLegalViewController() as? LegalViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
