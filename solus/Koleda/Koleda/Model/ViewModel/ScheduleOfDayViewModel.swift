//
//  ScheduleOfDayViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 10/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

enum DayOfWeek: String, Codable {
    case unknow
    case MONDAY     = "MONDAY"
    case TUESDAY    = "TUESDAY"
    case WEDNESDAY  = "WEDNESDAY"
    case THURSDAY   = "THURSDAY"
    case FRIDAY     = "FRIDAY"
    case SATURDAY   = "SATURDAY"
    case SUNDAY     = "SUNDAY"
    
    init(fromString string: String) {
        guard let value = DayOfWeek(rawValue: string) else {
            self = .unknow
            return
        }
        self = value
    }
    
    static var days: Int = 7
    
    var titleOfDay: String {
        switch self {
        case .MONDAY:
            return "MON_ABBR".app_localized
        case .TUESDAY:
            return "TUE_ABBR".app_localized
        case .WEDNESDAY:
            return "WED_ABBR".app_localized
        case .THURSDAY:
            return "THU_ABBR".app_localized
        case .FRIDAY:
            return "FRI_ABBR".app_localized
        case .SATURDAY:
            return "SAT_ABBR".app_localized
        case .SUNDAY:
            return "SUN_ABBR".app_localized
        default:
            return ""
        }
    }
    
    static func dayWithIndex(index: Int) -> String {
        switch index {
        case 0:
            return "Monday"
        case 1:
            return "Tuesday"
        case 2:
            return "Wednesday"
        case 3:
            return "Thursday"
        case 4:
            return "Friday"
        case 5:
            return "Saturday"
        default:
            return "Sunday"
        }
    }
}

enum RowType {
    case Header
    case Footer
    case Detail
}

struct ScheduleRow {
    let type: RowType
    let icon: UIImage?
    let title: String
    let temperature: Double?
    let temperatureUnit: String?
    
    init(type: RowType, title: String, icon: UIImage?, temp: Double?, unit: String?) {
        self.type = type
        self.icon = icon
        self.title = title
        self.temperature = temp
        self.temperatureUnit = unit
    }
}

struct ScheduleBlock {
    let color: UIColor
    let scheduleRows: [ScheduleRow]
    let rooms: [Room]
    let targetTemperature: Double
    init(color: UIColor, scheduleRows: [ScheduleRow], rooms: [Room], targetTemperature: Double) {
        self.color = color
        self.scheduleRows = scheduleRows
        self.rooms = rooms
        self.targetTemperature = targetTemperature
    }
}

class ScheduleOfDayViewModel {
    private (set) var scheduleOfDay: ScheduleOfDay?
    var rowsMergeData: [(startIndex: Int, numberRows: Int)] = []
    var startRowList: [Int] = []
    var displayData: [Int : ScheduleBlock] = [:]
    let currentTempUnit = UserDataManager.shared.temperatureUnit.rawValue
    init(scheduleOfDay: ScheduleOfDay? = nil) {
        guard let scheduleOfDay = scheduleOfDay else {
            return
        }
        self.scheduleOfDay = scheduleOfDay
        for scheduleOfTime in scheduleOfDay.details {
            
            var detailRoomsPopover: [Room] = []
            var dataOfScheduleRow: [ScheduleRow] = []
            let smartMode = ModeItem.getModeItem(with: SmartMode(fromString: scheduleOfTime.mode))
            let heaterRow = ScheduleRow(type: .Header, title: scheduleOfTime.mode, icon: smartMode?.icon , temp: smartMode?.temperature , unit: currentTempUnit)
            dataOfScheduleRow.append(heaterRow)
            //Get number of Row for this schedule
            guard let startTime = scheduleOfTime.from.removeSecondOfTime().timeValue(), let endTime = scheduleOfTime.to.removeSecondOfTime().timeValue()?.correctLocalTimeFormat() else {
                return
            }
            let startRow = (startTime.hour*60 + startTime.minute)/30
            let rowsNeedMerge = ((endTime.hour*60 + endTime.minute) - (startTime.hour*60 + startTime.minute))/30
            startRowList.append(startRow)
            if rowsNeedMerge > 1 {
                let roomsData = scheduleOfTime.rooms
                rowsMergeData.append((startRow, rowsNeedMerge))
                if roomsData.count <= rowsNeedMerge - 1 {
                    for room in roomsData {
                        let detailRow = ScheduleRow(type: .Detail, title: room.name, icon: nil, temp: room.temperature?.kld_doubleValue, unit: currentTempUnit)
                        dataOfScheduleRow.append(detailRow)
                    }
                } else {
                    let numberOfRoomsCannotShow = roomsData.count - (rowsNeedMerge - 2)
                    let numberOfRoomsWillShow = roomsData.count - numberOfRoomsCannotShow
                    if numberOfRoomsWillShow > 0 {
                        for indexRow in 0..<numberOfRoomsWillShow {
                            let room = roomsData[indexRow]
                            let detailRow = ScheduleRow(type: .Detail, title: room.name, icon: nil, temp: room.temperature?.kld_doubleValue, unit: currentTempUnit)
                            dataOfScheduleRow.append(detailRow)
                        }
                    }
                    let roomsString = String(format: "NUMBER_ROOMS_CAN_NOT_SHOW_MESSAGE".app_localized, numberOfRoomsCannotShow)
                    let moreRoomsString = String(format: "MORE_ROOMS_CAN_NOT_SHOW_MESSAGE".app_localized, numberOfRoomsCannotShow)
                    let title = rowsNeedMerge == 2 ? roomsString : moreRoomsString
                    let footerRow = ScheduleRow(type: .Footer, title: title, icon: nil, temp: nil, unit: nil)
                    dataOfScheduleRow.append(footerRow)
                    detailRoomsPopover = scheduleOfTime.rooms
                }
            } else {
                detailRoomsPopover = scheduleOfTime.rooms
            }
            
            let color: UIColor = smartMode?.color ?? UIColor.yellowLight
            displayData[startRow] = ScheduleBlock(color: color, scheduleRows: dataOfScheduleRow, rooms: detailRoomsPopover, targetTemperature: smartMode?.temperature ?? 0)
        }
    }
    
}
