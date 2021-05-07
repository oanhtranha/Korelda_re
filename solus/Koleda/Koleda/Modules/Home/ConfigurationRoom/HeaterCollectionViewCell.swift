//
//  HeaterCollectionViewCell.swift
//  Koleda
//
//  Created by Oanh tran on 8/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class HeaterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var heaterImageView: UIImageView!
    @IBOutlet weak var heaterNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func setup(with heater: Heater) {
        heaterNameLabel.text = heater.name
        if heater.enabled {
            statusLabel.text = "ACTIVE_TEXT".app_localized
            statusLabel.textColor = UIColor.green
        } else {
            statusLabel.text = "INACTIVE_TEXT".app_localized
            statusLabel.textColor =  UIColor.red
        }
    }
}
