//
//  RoomTypeCell.swift
//  Koleda
//
//  Created by Oanh tran on 7/9/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

class RoomTypeCell: UICollectionViewCell {
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var roomType: RoomType?
    override var isSelected: Bool {
        didSet {
            checkImage.isHidden = !isSelected
            backgroundImageView.isHidden = !isSelected
            typeImageView.tintColor = isSelected ? UIColor.black : UIColor.gray
            typeImageView.image = roomType?.roomDetailImage
            typeImageView.tintColor = isSelected ? UIColor.black: UIColor.gray
            titleLabel.textColor = isSelected ? UIColor.black : UIColor.hexB5B5B5
        }
    }
    
    func loadData(roomType: RoomType) {
        self.roomType = roomType
        typeImageView.image = roomType.roomDetailImage
        titleLabel.text = roomType.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isSelected = false
    }
}
