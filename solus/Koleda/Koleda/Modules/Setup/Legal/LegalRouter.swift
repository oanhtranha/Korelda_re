//
//  LegalRouter.swift
//  Koleda
//
//  Created by Oanh Tran on 11/8/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import UIKit

class LegalRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case privacyPolicy
        case termAndCondition
        case back
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
        case .privacyPolicy:
            let router = TermAndConditionRouter()
            let viewModel = TermAndConditionViewModel.init(router: router, legalItem: .legalPrivacyPolicy)
            guard let viewController = StoryboardScene.Setup.instantiateTermAndConditionViewController() as? TermAndConditionViewController else { return }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .termAndCondition:
            let router = TermAndConditionRouter()
            let viewModel = TermAndConditionViewModel.init(router: router, legalItem: .legalTermAndConditions)
            guard let viewController = StoryboardScene.Setup.instantiateTermAndConditionViewController() as? TermAndConditionViewController else { return }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        case .back:
            baseViewController.navigationController?.popViewController(animated: true)
        }
        
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
