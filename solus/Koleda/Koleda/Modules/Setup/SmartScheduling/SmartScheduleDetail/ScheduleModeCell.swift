//
//  ScheduleModeCell.swift
//  Koleda
//
//  Created by Oanh tran on 11/1/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ScheduleModeCell: UICollectionViewCell {

    @IBOutlet weak var modeView: ModeView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(with mode: ModeItem, isSelected: Bool, fromModifyModesScreen: Bool) {
        modeView.setUp(modeItem: mode)
        modeView.updateStatus(enable: isSelected, fromModifyModesScreen: fromModifyModesScreen)
    }

}
