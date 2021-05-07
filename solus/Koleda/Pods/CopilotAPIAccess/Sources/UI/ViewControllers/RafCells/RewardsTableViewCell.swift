//
//  RewardsTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

protocol RewardsTableViewCellDelegate: RafTableViewCellDelegate {
    func getDiscountButtonPressed(withValue value: String?, selectedRewardsSum: SelectedRewardsSum?, rewardsIds: [String])
    func termsApplyButtonPressed()
}

class RewardsTableViewCell: RafTableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noRewardLabel: UILabel!
    @IBOutlet weak var rewardsStackView: UIStackView!
    @IBOutlet weak var numOfRewardsLabel: UILabel!
    @IBOutlet weak var numOfRewardsStackView: UIStackView!
    @IBOutlet weak var numOfPendingRewardsLabel: UILabel!
    @IBOutlet weak var numOfPendingRewardsStackView: UIStackView!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var getDiscountButton: UIButton!
    @IBOutlet weak var termsApplyButton: UIButton!
    @IBOutlet weak var flagsImage: UIImageView!
    
    weak var delegate: RewardsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.allowsMultipleSelection = true
        termsApplyButton.underline()
        getDiscountButton.setBackgroundColor(color: .getDiscountHighlightedBackgroundColor, forState: .highlighted)
        getDiscountButton.setBackgroundColor(color: .getDiscountDisableBackgroundColor, forState: .disabled)
    }
    
    override func prepareForReuse() {
        getDiscountButton.isEnabled = !(collectionView.indexPathsForSelectedItems?.isEmpty ?? true)
    }
    
    //MARK: - IBActions
    
    @IBAction func getDiscountButtonPressed(_ sender: Any) {
        var selectedRewardsSumString: String? = nil
        var selectedRewardsIds = [String]()
        var selectedRewardsSum: SelectedRewardsSum? = nil
        
        if let logicModule = logicModule as? RewardsLogicModule {
            selectedRewardsSumString = logicModule.getSelectedRewardsSumString(self.collectionView, isCurrencyFirst: false)
            selectedRewardsIds = logicModule.getSelectedRewardsIds(self.collectionView)
            selectedRewardsSum = logicModule.getSelectedRewardsSum(self.collectionView)
        }
        
        let rafTapGetDiscountAnalyticsEvent = RafTapGetDiscountAnalyticsEvent(rewardAggregatedValue: selectedRewardsSum?.sum, rewardAggregatedCurrencyCode: selectedRewardsSum?.currency)
        Copilot.instance.report.log(event: rafTapGetDiscountAnalyticsEvent)
        
        delegate?.getDiscountButtonPressed(withValue: selectedRewardsSumString, selectedRewardsSum: selectedRewardsSum, rewardsIds: selectedRewardsIds)
    }
    
    @IBAction func termsApplyButtonPressed(_ sender: Any) {
        let rafTapTermsAndConditionsAnalyticsEvent = RafTapTermsAndConditionsAnalyticsEvent(termsLocation: .rewards)
        Copilot.instance.report.log(event: rafTapTermsAndConditionsAnalyticsEvent)
        
        delegate?.termsApplyButtonPressed()
    }
    
    override func setup(logicModule: RafCellLogicModule, delegate: RafTableViewCellDelegate?) {
        super.setup(logicModule: logicModule)
        
        self.delegate = delegate as? RewardsTableViewCellDelegate
        
        if let logicModule = logicModule as? RewardsLogicModule {
            self.collectionView.dataSource = logicModule
            self.collectionView.delegate = logicModule
            collectionViewHeightConstraint.constant = logicModule.getCollectionViewHeight()
            
            let isActiveOrPendingRewards = logicModule.numOfActiveRewards > 0 || logicModule.numOfPendingRewards > 0
            if isActiveOrPendingRewards {
                numOfRewardsLabel.text = String(logicModule.numOfActiveRewards)
                numOfPendingRewardsLabel.text = String(logicModule.numOfPendingRewards)
            }
            rewardsStackView.isHidden = !isActiveOrPendingRewards
            noRewardLabel.isHidden = isActiveOrPendingRewards
            
            flagsImage.isHidden = !logicModule.isAltruistic
            separatorLabel.isHidden = !(logicModule.numOfActiveRewards > 0 && logicModule.numOfPendingRewards > 0)
            numOfRewardsStackView.isHidden = !(logicModule.numOfActiveRewards > 0)
            numOfPendingRewardsStackView.isHidden = !(logicModule.numOfPendingRewards > 0)
            
            getDiscountButton.setTitle(LocalizationHelper.translatedStringForKey(key: Strings.Raf.getDiscount.rawValue), for: .normal)
            
            termsApplyButton.isHidden = logicModule.termsURLString == nil
        }
    }

}
