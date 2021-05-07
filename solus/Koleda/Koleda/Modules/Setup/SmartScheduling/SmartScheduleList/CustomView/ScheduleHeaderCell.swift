//
//  ScheduleHeaderCell.swift
//  Koleda
//
//  Created by Oanh tran on 10/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ScheduleHeaderCell: UITableViewCell {
    @IBOutlet weak var modeIconImageView: UIImageView!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(scheduleRow: ScheduleRow) {
        
        modeIconImageView.image = scheduleRow.icon
        modeLabel.text = scheduleRow.title + " MODE"
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
        
        if let mode = ModeItem.getModeItem(with: SmartMode(fromString: scheduleRow.title)) {
            modeIconImageView.tintColor = mode.color
        }
    }

}
