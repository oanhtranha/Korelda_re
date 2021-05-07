//
//  Date+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 8/29/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

extension Date {
    
    public static var fm_hhmma                = "hh:mm a"
    public static var fm_HHmm                = "HH:mm"
    
//    returns an integer from 1 - 7, with 1 being Sunday and 7 being Saturday
    func dayNumberOfWeek() -> Int {
        guard let dayNumber = Calendar.current.dateComponents([.weekday], from: self).weekday else {
            return 0
        }
        return dayNumber == 1 ? 6 : (dayNumber - 2)
    }
    
    func fomartAMOrPm() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss a"
        return formatter.string(from: self)
    }
    
    func adding(seconds: Int) -> Date {
        guard let newTime = Calendar.current.date(byAdding: .second, value: seconds, to: self) else {
            return Date()
        }
        return newTime
    }
    
    public init(str: String, format: String) {
        let fmt = DateFormatter()
        fmt.dateFormat = format
        fmt.timeZone = TimeZone.current
        fmt.locale = Locale(identifier: "en_US_POSIX")
        if let date = fmt.date(from: str) {
            self.init(timeInterval: 0, since: date)
        } else {
            self.init(timeInterval: 0, since: Date())
        }
    }
    
    public func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
