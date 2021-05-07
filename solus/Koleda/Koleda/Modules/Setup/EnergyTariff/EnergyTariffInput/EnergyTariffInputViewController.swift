//
//  EnergyTariffInputViewController.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
enum TypeInput: Int {
    case amountPerHourDay               = 0
    case dayStartTime                   = 1
    case dayEndTime                     = 2
    case amountPerHourNight            = 3
    case nightStartTime                = 4
    case nightEndTime                  = 5
    case scheduleStartTime             = 6
    case scheduleEndTime             = 7
    
}

protocol ScheduleTimeInputDelegate {
    func selectedTime(start: String, end: String)
}

protocol EnergyTariffInputDelegate {
    func selectedAmountPerHour(isDay: Bool, amount: Double, currencyUnit: String)
    func selectedTime(isDay: Bool, startTime: String, endTime: String)
}

class EnergyTariffInputViewController: UIViewController {
    var delegate: EnergyTariffInputDelegate?
    var scheduleTimeInputDelegate: ScheduleTimeInputDelegate?
    
    @IBOutlet weak var amountPerHourDayPricerView: UIPickerView!
    @IBOutlet weak var titleAmountPerHourView: UIView!
    @IBOutlet weak var titleTimeView: UIView!
    @IBOutlet weak var titleTimeLabel: UILabel!
    
    @IBOutlet weak var amountPerHourView: UIView!
    @IBOutlet weak var timePickerView: UIDatePicker!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var pricePerLabel: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var cancelLabel: UILabel!
    
    
    let currencyUnits:[String] = ["CHF", "EUR", "GBP", "USD", "AUD", "CAD"]
    var typeInput: TypeInput = .amountPerHourDay
    var amountPerHour: Double = 0
    var currencyUnit: String = ""
    var startTime: Date?
    var endTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func initView() {
        titleAmountPerHourView.isHidden = true
        titleTimeView.isHidden = true
        amountPerHourView.isHidden = true
        timePickerView.isHidden = true
        
        if typeInput == .amountPerHourDay || typeInput == .amountPerHourNight {
            titleAmountPerHourView.isHidden = false
            amountPerHourView.isHidden = false
            let index1 = Int(amountPerHour)
            let index2 = Int(amountPerHour * 100) % 100
            let index3 = currencyUnits.lastIndex(of: currencyUnit) ?? 0
            amountPerHourDayPricerView.selectRow(index1, inComponent: 0, animated: true)
            amountPerHourDayPricerView.selectRow(index2, inComponent: 2, animated: true)
            amountPerHourDayPricerView.selectRow(index3, inComponent: 3, animated: true)
        } else {
            titleTimeView.isHidden = false
            timePickerView.isHidden = false
            let isStart: Bool =  [.dayStartTime, .nightStartTime, .scheduleStartTime].contains(typeInput)
            startButton.isSelected = isStart
            endButton.isSelected = !isStart
            startButton.isHidden = !isStart
            endButton.isHidden = isStart
            let startTime: Date = self.startTime ?? Date.init()
            let endTime: Date = self.endTime ?? Date.init()
            if [.scheduleStartTime, .scheduleEndTime].contains(typeInput)  {
                timePickerView.minuteInterval = 30
                titleTimeLabel.text = "TIMESLOT_TEXT".app_localized
            } else {
                timePickerView.minuteInterval = 1
                let isDayTime: Bool = [.dayStartTime, .dayEndTime].contains(typeInput)
                titleTimeLabel.text = isDayTime ? "DAYTIME_TEXT".app_localized : "NIGHTTIME_TEXT".app_localized
            }
         
            if isStart {
                timePickerView.setDate(startTime, animated: true)
            } else {
                timePickerView.setDate(endTime, animated: true)
            }
        }
        pricePerLabel.text = "PRICE_FER_KWH".app_localized
        startButton.setTitle("START_TEXT".app_localized, for: .normal)
        endButton.setTitle("END_TEXT".app_localized, for: .normal)
        confirmLabel.text = "CONFIRM_TEXT".app_localized
        cancelLabel.text = "CANCEL".app_localized
    }

    @IBAction func confirmAction(_ sender: Any) {
        var startTimeString = ""
        if let startTime = self.startTime {
            startTimeString = startTime.toString(format: Date.fm_HHmm)
        } else if startButton.isSelected {
            startTimeString = Date.init().toString(format: Date.fm_HHmm)
        }
        var endTimeString = ""
        if let endTime = self.endTime {
            endTimeString = endTime.toString(format: Date.fm_HHmm)
        } else if endButton.isSelected {
            endTimeString = Date.init().toString(format: Date.fm_HHmm)
        }
        if [.scheduleStartTime, .scheduleEndTime].contains(typeInput) {
            scheduleTimeInputDelegate?.selectedTime(start: startTimeString, end: endTimeString)
            back()
        } else {
            if typeInput == .amountPerHourDay || typeInput == .amountPerHourNight {
                let index1 = amountPerHourDayPricerView.selectedRow(inComponent: 0)
                let index2 = amountPerHourDayPricerView.selectedRow(inComponent: 2)
                let index3 = amountPerHourDayPricerView.selectedRow(inComponent: 3)
                let amount = Double(index1) + Double(index2) * 0.01
                delegate?.selectedAmountPerHour(isDay: typeInput == .amountPerHourDay, amount: amount, currencyUnit: currencyUnits[index3])
            }  else if [.dayStartTime, .dayEndTime].contains(typeInput) {
                delegate?.selectedTime(isDay: true, startTime: startTimeString, endTime: endTimeString)
            } else if [.nightStartTime, .nightEndTime].contains(typeInput) {
                delegate?.selectedTime(isDay: false, startTime: startTimeString, endTime: endTimeString)
            }
            back()
        }
    }
    
    @IBAction func selectedStartTimeAction(_ sender: Any) {
        startButton.isSelected = true
        endButton.isSelected = false
        timePickerView.setDate(startTime ?? Date.init(), animated: true)
    }
    
    @IBAction func selectedEndTimeAction(_ sender: Any) {
        startButton.isSelected = false
        endButton.isSelected = true
        timePickerView.setDate(endTime ?? Date.init(), animated: true)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        back()
    }
    
    @IBAction func editedTimePicker(_ sender: UIDatePicker) {
        if startButton.isSelected == true {
            startTime = sender.date
        } else {
            endTime = sender.date
        }
    }
}

extension EnergyTariffInputViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == amountPerHourDayPricerView {
            return 4
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == amountPerHourDayPricerView {
            if component == 0 {
                return 2
            } else if component == 1 {
                return 1
            } else if component == 2 {
                return 100
            } else if component == 3 {
                return currencyUnits.count
            }
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == amountPerHourDayPricerView {
            if component == 0 {
                return String(format: "%01d", row)
            } else if component == 1 {
                return "."
            } else if component == 2 {
                return String(format: "%02d", row)
            } else if component == 3 {
                return currencyUnits[row]
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
}
