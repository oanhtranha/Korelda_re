//
//  LegalMenuCell.swift
//  Koleda
//
//  Created by Oanh Tran on 11/8/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit

class LegalMenuCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setText(title: String) {
        titleLabel.text = title
    }
}
