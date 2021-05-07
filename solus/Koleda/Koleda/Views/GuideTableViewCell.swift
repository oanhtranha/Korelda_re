//
//  GuideTableViewCell.swift
//  Koleda
//
//  Created by Oanh tran on 6/25/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class GuideTableViewCell: UITableViewCell {

    @IBOutlet weak var guideImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var guideItem: GuideItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(with guideItem: GuideItem) {
        guideImageView.image = guideItem.image
        titleLabel.text = guideItem.title
        messageLabel.text = guideItem.message
    }
    
}
