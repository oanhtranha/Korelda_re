//
//  ModifyModesRouter.swift
//  Koleda
//
//  Created by Oanh Tran on 2/3/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import UIKit

class ModifyModesRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case detailMode(ModeItem)
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
        case .detailMode(let selectedMode):
            let router = DetailModeRouter()
            let viewModel = DetailModeViewModel.init(router: router, selectedMode: selectedMode)
            guard let detailModeVC = StoryboardScene.Setup.instantiateDetailModeViewController() as? DetailModeViewController else {
                assertionFailure("Setup storyboard configured not properly")
                return
            }
            detailModeVC.viewModel = viewModel
            router.baseViewController = detailModeVC
            baseViewController.navigationController?.pushViewController(detailModeVC, animated: true)
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
