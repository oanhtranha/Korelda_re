
//
//  SmartScheduleDetailViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 10/31/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import CopilotAPIAccess

protocol SmartScheduleDetailViewModelProtocol: BaseViewModelProtocol {
    var timeslotTitle: Variable<String> { get }
    var smartModes: Variable<[ModeItem]>  { get }
    var startTime: Variable<String> { get }
    var endTime: Variable<String> { get }
    var selectedRooms: Variable<[Room]> { get }
    var selectedMode: Variable<ModeItem?> { get }
    var showMessageError: PublishSubject<String> { get }
    var hiddenDeleteButton: Variable<Bool> { get }
    
    func didSelectMode(atIndex: Int)
    func updateSchedules(completion: @escaping (Bool) -> Void)
    func deleteSchedules(completion: @escaping (Bool) -> Void)
}

class SmartScheduleDetailViewModel: BaseViewModel, SmartScheduleDetailViewModelProtocol {
    
    let router: BaseRouterProtocol
    private let schedulesManager: SchedulesManager
    
    let timeslotTitle = Variable<String>("")
    let smartModes = Variable<[ModeItem]>([])
    let startTime = Variable<String>("")
    let endTime = Variable<String>("")
    let selectedRooms = Variable<[Room]>([])
    let selectedMode = Variable<ModeItem?>(ModeItem.getModeItem(with: .ECO))
    var showMessageError = PublishSubject<String>()
    let hiddenDeleteButton = Variable<Bool>(true)
    private var dayOfWeek: String = ""
    private var scheduleOfTimesWithoutEditingScheduleTime: [ScheduleOfTime] = []
    private var scheduleOfTimesOfDay: [ScheduleOfTime] = []
    private var tapedTimeline: Bool = false
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, startTime: Time, dayOfWeek: DayOfWeek, tapedTimeline: Bool) {
        self.router =  router
        schedulesManager =  managerProvider.schedulesManager
        super.init(managerProvider: managerProvider)
        smartModes.value = UserDataManager.shared.settingModesWithoutDefaultMode()
        self.dayOfWeek = dayOfWeek.rawValue ?? ""
        self.tapedTimeline = tapedTimeline
        loadView(startTime: startTime)
    }
    
    func didSelectMode(atIndex: Int) {
        selectedMode.value = smartModes.value[atIndex]
    }
    
    func updateSchedules(completion: @escaping (Bool) -> Void) {
        guard validateData() else {
            completion(false)
            return
        }
        
        guard let scheduleOfDay = createScheduleOfDay() else {
            return
        }
        callServiceToUpdateSmartScheduleOfDay(scheduleOfDay: scheduleOfDay) { isSuccess in
            completion(isSuccess)
        }
    }
    
    func deleteSchedules(completion: @escaping (Bool) -> Void) {
        let scheduleOfDay: ScheduleOfDay = ScheduleOfDay(dayOfWeek: dayOfWeek, details: scheduleOfTimesWithoutEditingScheduleTime)
        callServiceToUpdateSmartScheduleOfDay(scheduleOfDay: scheduleOfDay) { isSuccess in
            completion(isSuccess)
        }
    }
    
    private func callServiceToUpdateSmartScheduleOfDay(scheduleOfDay: ScheduleOfDay, completion: @escaping (Bool) -> Void) {
        schedulesManager.updateSmartSchedule(schedules: scheduleOfDay, success: {
            Copilot.instance.report.log(event: SetSmartScheduleAnalyticsEvent(schedules: scheduleOfDay, screenName: self.screenName))
            completion(true)
        }) { error in
            completion(false)
        }
    }
    
    private func loadView(startTime: Time) {
        guard let scheduleOfDay = UserDataManager.shared.smartScheduleData[dayOfWeek] else {
            return
        }
        self.timeslotTitle.value =  String(format:"%@ %@", dayOfWeek.getStringLocalizeDay().capitalizingFirstLetter(), "TIMESLOT_TEXT".app_localized)
        if !tapedTimeline, let existScheduleOfTime = checkTimeHasScheduleOrNot(startTime: startTime.timeIntValue(), scheduleOfDay: scheduleOfDay) {
            self.startTime.value = existScheduleOfTime.from.removeSecondOfTime()
            self.endTime.value = existScheduleOfTime.to.correctLocalTimeStringFormatForDisplay.removeSecondOfTime()
            selectedMode.value = ModeItem.getModeItem(with: SmartMode.init(fromString: existScheduleOfTime.mode))
            selectedRooms.value = existScheduleOfTime.rooms
            hiddenDeleteButton.value = false
            scheduleOfTimesOfDay = scheduleOfTimesWithoutEditingScheduleTime
        } else {
            hiddenDeleteButton.value = true
            self.startTime.value = startTime.timeString()
            var endTimeSuggest = startTime.add(minutes: 60)
            if startTime.hour == 23 && startTime.minute == 30 {
                endTimeSuggest = startTime.add(minutes: 30)
            } else if let existScheduleOfTime = checkTimeHasScheduleOrNot(startTime: endTimeSuggest.timeIntValue(), scheduleOfDay: scheduleOfDay), let starttimeOfExistBlock = existScheduleOfTime.from.intValueWithLocalTime, starttimeOfExistBlock < endTimeSuggest.timeIntValue() && startTime.timeIntValue() < starttimeOfExistBlock {
                endTimeSuggest = startTime.add(minutes: 30)
            }
            self.endTime.value = endTimeSuggest.timeString()
            scheduleOfTimesOfDay = scheduleOfDay.details
        }
    }
    
    private func checkTimeHasScheduleOrNot(startTime: Int, scheduleOfDay: ScheduleOfDay) -> ScheduleOfTime? {
        for detail in scheduleOfDay.details {
            if let startOfDetail = detail.from.intValueWithLocalTime,
                let endOfDetail = detail.to.intValueWithLocalTime,
                startTime >= startOfDetail && startTime < endOfDetail {
                // (startTime >= startOfDetail || (startOfDetail - startTime) < 30) && startTime < endOfDetail && (endOfDetail - startTime) >= 30
                scheduleOfTimesWithoutEditingScheduleTime = scheduleOfDay.details.filter { $0.from != detail.from && $0.to != detail.to }
                return detail
            }
        }
        return nil
    }
    
    private func validateData() -> Bool {
        if startTime.value.isEmpty {
            showMessageError.onNext("START_TIMESLOT_IS_EMPTY_MESS".app_localized)
            return false
        }
        
        if endTime.value.isEmpty {
            showMessageError.onNext("END_TIMESLOT_IS_EMPTY_MESS".app_localized)
            return false
        }
        
        guard let startIntValue = startTime.value.timeValue()?.timeIntValue(), let endIntValue = endTime.value.timeValue()?.timeIntValue() else {
            showMessageError.onNext("INVALID_TIMESLOT_MESS")
            return false
        }
        
        if startIntValue >= endIntValue && endIntValue != 0 {
            showMessageError.onNext("END_TIMESLOT_MUST_BE_GREATER_MESS".app_localized)
            return false
        }
        
        if selectedRooms.value.count == 0 {
            showMessageError.onNext("PLEASE_CHOOSE_AT_LEAST_ONE_ROOM_MESS".app_localized)
            return false
        }
        
        return true
    }
    
    private func createScheduleOfDay() -> ScheduleOfDay? {
        guard let selectedMode = selectedMode.value else {
            return nil
        }
        var roomIds: [String] = []
        for room in selectedRooms.value {
            roomIds.append(room.id)
        }
        let editingScheduleOfTime = ScheduleOfTime(from: startTime.value.kld_localTimeFormat(), to: endTime.value.kld_localTimeFormat(), mode: selectedMode.mode.rawValue, roomIds: roomIds)
        guard let scheduleOfDay = UserDataManager.shared.smartScheduleData[dayOfWeek] else {
            return ScheduleOfDay(dayOfWeek: dayOfWeek, details: [editingScheduleOfTime])
        }
        var newDetailsSchedulesOfDay: [ScheduleOfTime] = []
        for detail in scheduleOfTimesOfDay {
            guard let startOfDetail = detail.from.removeSecondOfTime().timeValue(), let endOfDetail = detail.to.removeSecondOfTime().timeValue() else {
                return nil
            }
            let scheduleOfTimeAfterSplit = checkToSplitSchedule(start: startOfDetail.timeIntValue(), end: endOfDetail.timeIntValue(), oldSchedule: detail)
            newDetailsSchedulesOfDay.append(contentsOf: scheduleOfTimeAfterSplit)
        }
        newDetailsSchedulesOfDay.append(editingScheduleOfTime)
        return ScheduleOfDay(dayOfWeek: dayOfWeek, details: newDetailsSchedulesOfDay)
    }
    
    private func checkToSplitSchedule(start: Int, end: Int, oldSchedule: ScheduleOfTime) -> [ScheduleOfTime] {
        guard let startTimeValue = startTime.value.timeValue(), let endTimeValue = endTime.value.timeValue() else {
            return []
        }
        let editingStart: Int = startTimeValue.timeIntValue()
        let editingEnd: Int = endTimeValue.timeIntValue()
        
        var scheduleOfTimes: [ScheduleOfTime] = []
        
        if start < editingStart {
            if end <= editingStart {
                scheduleOfTimes.append(oldSchedule)
            } else if end > editingStart && end <= editingEnd{
                scheduleOfTimes.append(ScheduleOfTime(from: start.fullTimeWithHourAndMinuteFormat(), to: editingStart.fullTimeWithHourAndMinuteFormat(), mode: oldSchedule.mode, roomIds: oldSchedule.roomIds))
            } else if end > editingEnd {
                scheduleOfTimes.append(ScheduleOfTime(from: start.fullTimeWithHourAndMinuteFormat(), to: editingStart.fullTimeWithHourAndMinuteFormat(), mode: oldSchedule.mode, roomIds: oldSchedule.roomIds))
                scheduleOfTimes.append(ScheduleOfTime(from: editingEnd.fullTimeWithHourAndMinuteFormat(), to: end.fullTimeWithHourAndMinuteFormat(), mode: oldSchedule.mode, roomIds: oldSchedule.roomIds))
            }
        } else if start >= editingStart && start < editingEnd && end > editingEnd {
            scheduleOfTimes.append(ScheduleOfTime(from: editingEnd.fullTimeWithHourAndMinuteFormat(), to: end.fullTimeWithHourAndMinuteFormat(), mode: oldSchedule.mode, roomIds: oldSchedule.roomIds))
        } else if start >= editingEnd && end >= editingEnd {
            scheduleOfTimes.append(oldSchedule)
        }
        return scheduleOfTimes
    }
}
