//
//  ScheduleFooterCell.swift
//  Koleda
//
//  Created by Oanh tran on 10/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class ScheduleFooterCell: UITableViewCell {
    @IBOutlet weak var roomsLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(scheduleRow: ScheduleRow) {
        roomsLabel.text = scheduleRow.title
    }

}
