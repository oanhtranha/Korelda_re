//
//  DynamicContentTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 18/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit
import Kingfisher

class DynamicContentTableViewCell: UITableViewCell {

    @IBOutlet weak var contentview: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var contentImage: UIImageView!
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted {
            contentview.setHighlightedShadow()
        } else {
            contentview.setShadow()
        }
        
        contentview.backgroundColor = highlighted ? .dynamicDataHighlightedBackgroundColor : .dynamicDataDefaultBackgroundColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func set(title: String, imageURLString: String?, description: String, auxiliaryText: String?) {
        if let auxiliaryText = auxiliaryText {
            priceLabel.text = auxiliaryText
        } else {
            priceLabel.isHidden = true
        }
        titleLabel.text = title
        descriptionLabel.text = description
        
        if let imageURLString = imageURLString, let url = URL(string: imageURLString) {
            let resource = ImageResource(downloadURL: url)
            contentImage.kf.setImage(with: resource)
        }
    }

}
