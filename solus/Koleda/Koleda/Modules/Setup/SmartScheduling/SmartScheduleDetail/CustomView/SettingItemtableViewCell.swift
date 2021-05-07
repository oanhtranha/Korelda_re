//
//  SettingItemtableViewCell.swift
//  Koleda
//
//  Created by Oanh tran on 9/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class SettingItemtableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(menuItem: SettingMenuItem) {
        titleLabel.text = menuItem.title
        iconImageView.image = menuItem.icon
    }

}
