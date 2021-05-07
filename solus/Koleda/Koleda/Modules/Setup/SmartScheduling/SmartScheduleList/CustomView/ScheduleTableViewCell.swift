//
//  ScheduleTableViewCell.swift
//  Koleda
//
//  Created by Oanh tran on 10/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {
    @IBOutlet weak var statusIconImageView: UIImageView!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(scheduleRow: ScheduleRow, targetTemperature: Double) {
        roomNameLabel.text = scheduleRow.title
        guard let temp = scheduleRow.temperature else {
            temperatureLabel.text = "-"
            return
        }
        guard let unit = scheduleRow.temperatureUnit else {
            return
        }
        if TemperatureUnit.C.rawValue == unit {
            temperatureLabel.text = temp.toString()
        } else {
            temperatureLabel.text = temp.fahrenheitTemperature.toString()
        }
        unitLabel.text = "°\(unit)"
        
        statusIconImageView.isHidden = (temp == targetTemperature)
        if temp < targetTemperature {
            statusIconImageView.image = UIImage(named: "ic-heating-up-small")
        } else if temp > targetTemperature {
           statusIconImageView.image = UIImage(named: "ic-cooling-down-small")
        }
        
    }
}
