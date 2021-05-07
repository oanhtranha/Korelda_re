//
//  HeaterCollectionReusableView.swift
//  Koleda
//
//  Created by Oanh Tran on 10/5/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit

class HeaterCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var heaterTitleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        heaterTitleLabel.text = "HEATERS_TEXT".app_localized
    }
}
