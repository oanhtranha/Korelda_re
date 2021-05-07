//
//  HomeRouter.swift
//  Koleda
//
//  Created by Oanh tran on 6/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class HomeRouter: BaseRouterProtocol {
    
    enum RouteType {
        case addRoom
        case editRoom(Room)
        case selectedRoom(Room)
        case selectedRoomConfiguration(Room)
        case menuSettings
        case logOut
    }
    
    weak var baseViewController: UIViewController?
    
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
        case .addRoom:
            let router = RoomDetailRouter()
            let viewModel = RoomDetailViewModel.init(router: router)
            guard let viewController = StoryboardScene.Room.instantiateRoomDetailViewController() as? RoomDetailViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .editRoom(let selectedRoom):
            let router = RoomDetailRouter()
            let viewModel = RoomDetailViewModel.init(router: router, editingRoom: selectedRoom)
            guard let viewController = StoryboardScene.Room.instantiateRoomDetailViewController() as? RoomDetailViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .selectedRoom(let selectedRoom):
            let router = SelectedRoomRouter()
            let viewModel = SelectedRoomViewModel.init(router: router, seletedRoom: selectedRoom)
            guard let viewController = StoryboardScene.Home.instantiateSelectedRoomViewController() as? SelectedRoomViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .selectedRoomConfiguration(let selectedRoom):
            let router = ConfigurationRoomRouter()
            let viewModel = ConfigurationRoomViewModel.init(router: router, seletedRoom: selectedRoom)
            guard let viewController = StoryboardScene.Home.instantiateConfigurationRoomViewController() as? ConfigurationRoomViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .menuSettings:
            let router = MenuSettingsRouter()
            let viewModel = MenuSettingsViewModel.init(router: router)
            guard let viewController = StoryboardScene.Setup.instantiateMenuSettingsViewController() as? MenuSettingsViewController else {
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .logOut:
            let router = OnboardingRouter()
            let viewModel = OnboardingViewModel.init(with: router)
            let onboaringNavigationVC = StoryboardScene.Onboarding.instantiateNavigationController()
            
            guard let viewController = onboaringNavigationVC.topViewController as? OnboardingViewController else {
                assertionFailure("OnBoarding storyboard configured not properly")
                return
            }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.window?.rootViewController = onboaringNavigationVC
            }
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
    
    func dismiss(animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
