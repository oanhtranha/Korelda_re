//
//  TemperatureUnitView.swift
//  Koleda
//
//  Created by Oanh tran on 9/17/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation


import UIKit

class TemperatureUnitView: UIView {
    
    func setUp(unit: TemperatureUnit) {
        self.unit = unit
        abbUnitLabel.text = unit == .C ? "C °" : "F °"
        unitLabel.text = unit == .C ? "CELSIUS_TEXT".app_localized : "FAHRENHEIT_TEXT".app_localized
        updateStatus(enable: false)
    }
    @IBOutlet weak var abbUnitLabel: UILabel!
    @IBOutlet weak var lineLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    var unit: TemperatureUnit?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        kld_loadContentFromNib()
    }
    
    func updateStatus(enable: Bool) {
        abbUnitLabel.textColor = enable ? .black : .lightGray
        unitLabel.textColor = enable ? .black : .lightGray
        lineLabel.backgroundColor = enable ? .orange : .lightGray
    }
    
}
