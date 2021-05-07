//
//  RewardCollectionViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class RewardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var rewardImage: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            updateRewardStatus(bySelection: isSelected)
        }
    }
    
    override func prepareForReuse() {
        cellView.removeShadow()
        isSelected = false
    }
    
    //MARK: - Public Functions
    
    func set(rewardStatus: RewardStatus, value: Double, currency: String) {
        rewardImage.image = rewardStatus.image
        
        if rewardStatus == .returned || rewardStatus == .claimed {
            currencyLabel.textColor = .rewardDisableTextColor
            currencyLabel.text = rewardStatus.rewardTypeString
            if let font = UIFont.SFProTextRegularFont(size: 12) {
                currencyLabel.font = font
            }
        } else {
            currencyLabel.textColor = rewardStatus == .active ? .black : .rewardDisableCurrencyTextColor
            currencyLabel.text = currency + value.format(f: value.smartPercision)
            if let font = UIFont.SFProTextRegularFont(size: 19) {
                currencyLabel.font = font
            }
        }
    }
    
    //MARK: - Private
    
    private func updateRewardStatus(bySelection isSelected: Bool) {
        cellView.backgroundColor = isSelected ? .rewardSelectedBackgroundColor : .white
        currencyLabel.textColor = isSelected ? .white : .black
    }
}
