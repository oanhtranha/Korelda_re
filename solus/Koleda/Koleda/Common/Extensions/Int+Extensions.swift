//
//  Int+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 9/18/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

extension Int {
    
    func fullTimeFormart() -> String {
        
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = self
        
        if seconds >= 3600 {
            hours = self/3600
            seconds = self%3600
        }
        
        if seconds >= 60 {
            minutes = seconds/60
            seconds = seconds%60
        }
        
        let hoursString = hours > 9 ? "\(hours)" : "0\(hours)"
        let minutesString = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        
        return "\(hoursString):\(minutesString):\(secondsString)"
    }
    
    func fullTimeWithHourAndMinuteFormat() -> String {
        var hours: Int = 0
        var minutes: Int = self
        
        
        if minutes >= 60 {
            hours = minutes/60
            minutes = minutes%60
        }
        
        let hoursString = hours > 9 ? "\(hours)":"0\(hours)"
        let minutesString = minutes > 9 ? "\(minutes)":"0\(minutes)"
        
        return "\(hoursString):\(minutesString):00"
    }
}
