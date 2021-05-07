//
//  SmartSchedulingViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 10/22/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol SmartSchedulingViewModelProtocol: BaseViewModelProtocol {
    func showScheduleDetail(startTime: Time, day: DayOfWeek, tapedTimeline: Bool)
    var currentSelectedIndex: Int { set get }
}

class SmartSchedulingViewModel: BaseViewModel, SmartSchedulingViewModelProtocol {
    
    let router: BaseRouterProtocol
    private let settingManager: SettingManager
    
    var currentSelectedIndex: Int = 0
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router =  router
        settingManager =  managerProvider.settingManager
        super.init(managerProvider: managerProvider)
    }
    
    func showScheduleDetail(startTime: Time, day: DayOfWeek, tapedTimeline: Bool) {
        router.enqueueRoute(with: SmartSchedulingRouter.RouteType.scheduleDetail(startTime, day, tapedTimeline), completion: nil)
    }
}
