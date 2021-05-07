
//
//  SmartSchedulingRouter.swift
//  Koleda
//
//  Created by Oanh tran on 10/22/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

class SmartSchedulingRouter: BaseRouterProtocol {
    
    weak var baseViewController: UIViewController?
    
    enum RouteType {
        case scheduleDetail(Time, DayOfWeek, Bool)
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
        case .scheduleDetail(let startTime, let day, let tapedTimeline):
            let router = SmartScheduleDetailRouter()
            let viewModel = SmartScheduleDetailViewModel.init(router: router, startTime: startTime, dayOfWeek: day, tapedTimeline: tapedTimeline)
            guard let viewController = StoryboardScene.SmartSchedule.instantiateSmartScheduleDetailViewController() as? SmartScheduleDetailViewController else { return }
            viewController.viewModel = viewModel
            router.baseViewController = viewController
            baseViewController.navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }
    
    func present(on baseVC: UIViewController, animated: Bool, context: Any?, completion: ((Bool) -> Void)?) {
        
    }
}
