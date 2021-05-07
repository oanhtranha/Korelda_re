//
//  TimePickerViewController.swift
//  Koleda
//
//  Created by Oanh tran on 8/1/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Foundation
import RxSwift

struct Time {
    let hour: Int
    let minute: Int
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    func timeString() -> String {
        var hourString = "\(hour)"
        var minuteString = "\(minute)"
        if hour < 10 {
            hourString = "0\(hour)"
        }
        if minute < 10 {
            minuteString = "0\(minute)"
        }
        return "\(hourString):\(minuteString)"
    }
    
    func timeIntValue() -> Int {
        return hour*60 + minute
    }
    
    func correctLocalTimeFormat() -> Time {
        if self.hour == 23 && self.minute == 59 {
            return Time(hour: 24, minute: 0)
        } else {
            return self
        }
    }
    
    func add(minutes: Int) -> Time {
        let totalMinutes = self.minute + minutes
        if totalMinutes >= 60 {
            return Time(hour: self.hour + 1, minute: totalMinutes - 60)
        } else {
            return Time(hour: self.hour, minute: totalMinutes)
        }
    }
}

enum  TimePoint {
    case startOfDay
    case endOfDay
    case startOfNight
    case endOfNight
}

protocol TimePickerViewControllerDelegate: class {
    func selectedTime(time: Time)
}


class TimePickerViewController: UIViewController {

    weak var delegate: TimePickerViewControllerDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    private let disposeBag = DisposeBag()
    private var timePoint: TimePoint = .startOfDay
    private var time: Time? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Style.Button.primary.apply(to: setButton)
        Style.View.cornerRadius.apply(to: contentView)
        dateTimePicker.datePickerMode = .time
        setup()
    }
    
    func initTimePicker(timePoint: TimePoint, time: String) {
        self.timePoint = timePoint
        self.time = time.timeValue()
    }
    
    @IBAction func setTime(_ sender: Any) {
        let date = dateTimePicker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else {
            return
        }
        delegate?.selectedTime(time: Time(hour: hour, minute: minute))
    }
    
    private func setup() {
        switch timePoint {
        case .startOfDay:
            titleLabel.text = "Set start daytime tariff"
        case .endOfDay:
            titleLabel.text = "Set end daytime tariff"
        case .startOfNight:
            titleLabel.text = "Set start nighttime tariff"
        case .endOfNight:
            titleLabel.text = "Set end nighttime tariff"
        }
        guard let time = self.time else {
            return
        }
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = time.hour
        components.minute = time.minute
        dateTimePicker.setDate(calendar.date(from: components)!, animated: false)
    }
}
