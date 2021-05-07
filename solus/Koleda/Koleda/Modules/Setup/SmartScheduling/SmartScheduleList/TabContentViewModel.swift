//
//  TabContentViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 10/31/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import SpreadsheetView
import SVProgressHUD

protocol TabContentViewModelProtocol: BaseViewModelProtocol {
    var hoursData: [String] { get }
    var scheduleOfDayViewModel: ScheduleOfDayViewModel { get }
    var mergeCellData: [CellRange] { get }
    var dayOfWeek: DayOfWeek { get set }
    var reloadScheduleView: PublishSubject<Void> { get }
    func getScheduleOfDay(comletion: @escaping () -> Void) 
}

class TabContentViewModel: BaseViewModel, TabContentViewModelProtocol {
    
    let router: BaseRouterProtocol
    var hoursData: [String] = []
    var scheduleOfDayViewModel = ScheduleOfDayViewModel.init()
    var mergeCellData: [CellRange] = []
    var dayOfWeek: DayOfWeek = DayOfWeek.MONDAY
    let reloadScheduleView = PublishSubject<Void>()
    
    private let schedulesManager: SchedulesManager
    private var scheduleOfDay: ScheduleOfDay?
    
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance) {
        self.router =  router
        self.schedulesManager = managerProvider.schedulesManager
        super.init(managerProvider: managerProvider)
        hoursData = createTimeline()
        
    }
    
    func setup(dayOfWeek: DayOfWeek) {
        self.dayOfWeek = dayOfWeek
        guard let scheduleOfDay = UserDataManager.shared.smartScheduleData[dayOfWeek.rawValue] else {
            return
        }
        self.scheduleOfDay = scheduleOfDay
        updateScheduleView()
    }
    
    
    func getScheduleOfDay(comletion: @escaping () -> Void) {
        let dayString = self.dayOfWeek.rawValue
        schedulesManager.getSmartSchedule(dayString: dayString, success: { [weak self] in
            guard let schedules = UserDataManager.shared.smartScheduleData[dayString] else {
                return
            }
            self?.scheduleOfDay = schedules
            self?.updateScheduleView()
            comletion()
        }) { error in
            comletion()
        }
    }
    
    private func updateScheduleView() {
        guard let scheduleOfDay = self.scheduleOfDay else {
            return
        }
        self.scheduleOfDayViewModel = ScheduleOfDayViewModel.init(scheduleOfDay: scheduleOfDay)
        self.mergeCellData = self.getMergeCellData(rowsMergeData: scheduleOfDayViewModel.rowsMergeData)
        self.reloadScheduleView.onNext(())
    }
    
    private func getMergeCellData(rowsMergeData: [(startIndex: Int, numberRows: Int)]) -> [CellRange] {
        var mergeData: [CellRange] = []
        for data in rowsMergeData {
            if data.numberRows > 1 {
                let startRow = data.startIndex
                let endRow = (data.startIndex + data.numberRows) - 1
                
                mergeData.append(CellRange(from: (row: startRow, column: 1), to: (row: endRow, column: 1)))
            }
        }
        return mergeData
    }
    
    private func createTimeline() -> [String] {
        var hours: [String] = []
        var startValue = 0
        while startValue <= 23 {
            hours.append("\(startValue) : 00")
            hours.append("–")
            startValue += 1
        }
        hours.append("00 : 00")
        return hours
    }
}
