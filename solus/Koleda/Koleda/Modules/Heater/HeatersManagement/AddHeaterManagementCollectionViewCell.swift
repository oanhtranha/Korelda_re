//
//  AddHeaterManagementCollectionViewCell.swift
//  Koleda
//
//  Created by Vu Xuan Hoa on 9/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class AddHeaterManagementCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var solusLabel: UILabel!
    @IBOutlet weak var freeSlotLabel: UILabel!
    
    func setup() {
        solusLabel.text = "SOLUS_TEXT".app_localized
        freeSlotLabel.text = "FREE_SLOT_TEXT".app_localized
        addButton.setTitle("ADD_TEXT".app_localized, for: .normal)
    }
}
