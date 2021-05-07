//
//  RewardsLogicModule.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

struct SelectedRewardsSum {
    let sum: Double
    let currency: String
}

class RewardsLogicModule: RafCellLogicModule {
    
    private let dataSource: [Reward]
    private let rafProgram: RafProgram?
    private let termsOfUseUrl: String?
    
    private let maxNumOfPresentedRewards = 20
    
    init(isAltruistic: Bool, rafProgram: RafProgram? = nil, rewards: [Reward], termsOfUseUrl: String?) {
        self.rafProgram = rafProgram
        self.termsOfUseUrl = termsOfUseUrl
        
        var finalRewards = rewards
        
        finalRewards = finalRewards.sorted { $0.status < $1.status }
        
        if let rafProgram = self.rafProgram {
            var newRewardsArr = finalRewards
            
            var dummies = 0
            if rewards.count < maxNumOfPresentedRewards {
                if rewards.count < (2 * 4) {
                    dummies = (2 * 4) - rewards.count
                } else {
                    dummies = 4 - rewards.count % 4
                }
            }
            
            if dummies > 0 {
                for _ in 1...dummies {
                    newRewardsArr.append(Reward(id: nil, status: .dummy, value: rafProgram.rewardValue, currency: rafProgram.rewardCurrencySymbol))
                }
            }
            
            finalRewards = newRewardsArr
        } else {
            finalRewards = finalRewards.filter({ $0.status == .active || $0.status == .pending || $0.status == .claimed})
        }
        
        dataSource = finalRewards
    }
    
    var numOfActiveRewards: Int {
        return dataSource.filter({ $0.status == .active }).count
    }
    
    var numOfPendingRewards: Int {
        return dataSource.filter({ $0.status == .pending }).count
    }
    
    var isAltruistic: Bool {
        return rafProgram == nil
    }
    
    var termsURLString: String? {
        return termsOfUseUrl
    }
    
    func getCollectionViewHeight() -> CGFloat {
        let numOfRewards = dataSource.count > maxNumOfPresentedRewards ? maxNumOfPresentedRewards : dataSource.count
        let numOfRows = (Double(numOfRewards)/4.0).rounded(.up)
        return 89 * CGFloat(numOfRows)
    }
    
    //MARK: - CellLogicModule
    
    override var cellIdentifier: String {
        get {
            return RewardsTableViewCell.stringFromClass()
        }
    }
    
    override func getEstimatedCellHeight() -> CGFloat {
        return 300
    }
    
    private func allEqualUsingLoop<T : Equatable>(array : [T]) -> Bool {
        if let firstElem = array.first {
            for elem in array {
                if elem != firstElem {
                    return false
                }
            }
        }
        return true
    }
    
    func updateDiscountCodeButtonIfNeeded(_ collectionView: UICollectionView) {
        if let cell = delegate?.cellLogicModuleCellForLogicModule(logicModule: self) as? RewardsTableViewCell {
            var buttonTitle = "\(LocalizationHelper.translatedStringForKey(key: Strings.Raf.getDiscount.rawValue))"
            
            if let selectedRewardsSumString = getSelectedRewardsSumString(collectionView, isCurrencyFirst: true) {
                buttonTitle = "\(LocalizationHelper.translatedStringForKey(key: Strings.Raf.getDiscount.rawValue)) (\(selectedRewardsSumString))"
            }
            
            cell.getDiscountButton.setTitle(buttonTitle, for: .normal)
            cell.getDiscountButton.isEnabled = !(collectionView.indexPathsForSelectedItems?.isEmpty ?? true)
        }
    }
    
    func getSelectedRewardsIds(_ collectionView: UICollectionView) -> [String] {
        var rewardsIds = [String]()
        let isRewardsSelected = !(collectionView.indexPathsForSelectedItems?.isEmpty ?? true)
        
        if isRewardsSelected {
            if let selectedRewardIndexPaths = collectionView.indexPathsForSelectedItems {
                for indexPath in selectedRewardIndexPaths {
                    if let id = dataSource[indexPath.row].id {
                        rewardsIds.append(id)
                    }
                }
            }
        }
        
        return rewardsIds
    }
    
    func getSelectedRewardsSum(_ collectionView: UICollectionView) -> SelectedRewardsSum? {
        var selectedRewardsSum: SelectedRewardsSum?
        
        let isRewardsSelected = !(collectionView.indexPathsForSelectedItems?.isEmpty ?? true)
        
        if isRewardsSelected {
            var rewards = [Reward]()
            if let selectedRewardIndexPaths = collectionView.indexPathsForSelectedItems {
                for indexPath in selectedRewardIndexPaths {
                    rewards.append(dataSource[indexPath.row])
                }
            }
            
            let allItemsEqual = rewards.dropLast().allSatisfy { $0.currency == rewards.last?.currency }
            let currency = rewards.first?.currency ?? ""
            if allItemsEqual {
                var sum: Double = 0
                for reward in rewards {
                    sum += reward.value
                }
                
                selectedRewardsSum = SelectedRewardsSum(sum: sum, currency: currency)
            }
        }
        
        return selectedRewardsSum
    }
    
    func getSelectedRewardsSumString(_ collectionView: UICollectionView, isCurrencyFirst: Bool) -> String? {
        var rewardsSumString: String? = nil
        
        if let selectedRewardsSum = getSelectedRewardsSum(collectionView) {
            rewardsSumString = isCurrencyFirst ? selectedRewardsSum.currency + selectedRewardsSum.sum.format(f: selectedRewardsSum.sum.smartPercision) : selectedRewardsSum.sum.format(f: selectedRewardsSum.sum.smartPercision) + selectedRewardsSum.currency
        }
        
        return rewardsSumString
    }
    
    private func logRafTapRewardCreditAnalyticsEvent(_ collectionView: UICollectionView, selectedIndexPath indexPath: IndexPath ,rewardIsSelected: Bool) {
        let reward = dataSource[indexPath.row]
        let selectedRewardsSum = getSelectedRewardsSum(collectionView)
        let rafTapRewardCreditAnalyticsEvent = RafTapRewardCreditAnalyticsEvent(rewardValue: reward.value, rewardIsSelected: rewardIsSelected, rewardCurrencyCode: reward.currency, rewardSumAvailable: selectedRewardsSum?.sum)
        Copilot.instance.report.log(event: rafTapRewardCreditAnalyticsEvent)
    }
    
}

//MARK: - UICollectionViewDataSource
extension RewardsLogicModule: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var generalCell = UICollectionViewCell()
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RewardCollectionViewCell.stringFromClass(), for: indexPath) as? RewardCollectionViewCell {
            
            let reward = dataSource[indexPath.row]
            cell.set(rewardStatus: reward.status, value: reward.value, currency: reward.currency)
            
            if reward.status != .dummy {
                cell.cellView.setShadow()
            }
            
            generalCell = cell
        }
        
        return generalCell
    }
    
}

extension RewardsLogicModule: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let reward = dataSource[indexPath.row]
        
        return reward.status == .active
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateDiscountCodeButtonIfNeeded(collectionView)
        logRafTapRewardCreditAnalyticsEvent(collectionView, selectedIndexPath: indexPath, rewardIsSelected: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateDiscountCodeButtonIfNeeded(collectionView)
        logRafTapRewardCreditAnalyticsEvent(collectionView, selectedIndexPath: indexPath, rewardIsSelected: false)
    }
}


