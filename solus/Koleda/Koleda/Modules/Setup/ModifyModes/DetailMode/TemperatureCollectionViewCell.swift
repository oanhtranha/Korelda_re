//
//  TemperatureCollectionViewCell.swift
//  Koleda
//
//  Created by Oanh Tran on 2/4/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit

class TemperatureCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var selectedTemperatureView: UIView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var selectedTempLabel: UILabel!
    @IBOutlet weak var tempUnitLabel: UILabel!
    
    func setup(temp: Int, currentTempOfMode: Int) {
        let isSelected = (temp == currentTempOfMode)
        let currentTempUnit = UserDataManager.shared.temperatureUnit.rawValue
        temperatureView.isHidden = isSelected
        selectedTemperatureView.isHidden = !isSelected
        var tempDisplay = Double(temp)
        if TemperatureUnit.F.rawValue == currentTempUnit {
            tempDisplay = tempDisplay.fahrenheitTemperature
        }
        tempUnitLabel.text = "°\(currentTempUnit)"
        if isSelected {
            selectedTempLabel.text = String(format: "%.f", tempDisplay)
        } else {
            tempLabel.text = String(format: "%.f", tempDisplay)
        }
    }
}
