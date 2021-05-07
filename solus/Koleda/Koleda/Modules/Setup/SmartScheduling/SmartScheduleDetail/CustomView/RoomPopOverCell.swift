//
//  RoomPopOverCell.swift
//  Koleda
//
//  Created by Oanh tran on 9/10/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class RoomPopOverCell: UITableViewCell {

    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var roomNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func loadData(room: Room, isSelected: Bool) {
        roomNameLabel.text = room.name
        checkMarkImageView.isHidden = !isSelected
        self.isSelected = isSelected
    }
}
