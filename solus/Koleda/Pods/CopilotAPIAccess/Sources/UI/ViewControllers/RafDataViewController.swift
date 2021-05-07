//
//  RafDataViewController.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 01/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit
import CopilotLogger

protocol RafDataViewControllerDelegate: class {
    func failedOnUnauthorized()
    func rafDataUpdated()
}

class RafDataViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var logicModules = [RafCellLogicModule]()
    var rafData: RafData?
    
    weak var delegate: RafDataViewControllerDelegate?
    
    private var generateCouponWorker: RafPollingWorker<GenerateReferralCouponError>?
    private var claimCreditWorker: RafPollingWorker<ClaimCreditError>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        if let rafData = self.rafData {
            var rafScreenLoadAnalyticsEvent: RafScreenLoadAnalyticsEvent
            if rafData.isAltruisticProgram {
                rafScreenLoadAnalyticsEvent = RafScreenLoadAnalyticsEvent(programType: .altruistic, hasBalance: true)
            } else {
                rafScreenLoadAnalyticsEvent = RafScreenLoadAnalyticsEvent(programType: .activeProgram, hasBalance: true)
            }
            Copilot.instance.report.log(event: rafScreenLoadAnalyticsEvent)
            
            logicModules = updateLogicModules(byRafData: rafData)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        generateCouponWorker?.stopExecution()
    }

    @IBAction func shareButtonPressed(_ sender: Any) {
        let rafTapShareReferralCouponAnalyticsEvent = RafTapShareReferralCouponAnalyticsEvent(programType: .activeProgram)
        Copilot.instance.report.log(event: rafTapShareReferralCouponAnalyticsEvent)
        
        guard let rafData = self.rafData else {
            ZLogManagerWrapper.sharedInstance.logError(message: "No raf data")
            return
        }
        
        if rafData.isAltruisticProgram {
            self.shareText(rafData.altruisticProgram.shareText)
        } else {
            if let shareText = rafData.rafProgram?.shareText {
                self.shareText(shareText)
            } else {
                showLoadingView()
                
                generateCouponWorker = Copilot.instance.referAFriend.getGenerateCouponWorker { [weak self] (response) in
                    self?.hideLoadingView() { [weak self] in
                        let referralCodeGenerationSucceeded: Bool
                        
                        switch response {
                        case .success(let rafData):
                            referralCodeGenerationSucceeded = true
                            
                            self?.rafData = rafData
                            if let shareText = rafData.rafProgram?.shareText {
                                self?.shareText(shareText)
                            } else {
                                let generalErrorAlert = AppAlert.generalError
                                self?.presentAlertControllerWithPopupRepresentable(generalErrorAlert, cancelButtonText: LocalizationHelper.translatedStringForKey(key: Strings.Raf.cancel.rawValue))
                            }
                            
                        case .failure(let error):
                            referralCodeGenerationSucceeded = false
                            
                            switch error {
                            case .requiresRelogin(_):
                                self?.delegate?.failedOnUnauthorized()
                                
                            case .generalError(_):
                                let generalErrorAlert = AppAlert.generalError
                                self?.presentAlertControllerWithPopupRepresentable(generalErrorAlert, cancelButtonText: LocalizationHelper.translatedStringForKey(key: Strings.Raf.cancel.rawValue))
                                
                            case .connectivityError(_):
                                let connectivityErrorAlert = AppAlert.connectivityError
                                self?.presentAlertControllerWithPopupRepresentable(connectivityErrorAlert, cancelButtonText: LocalizationHelper.translatedStringForKey(key: Strings.Raf.cancel.rawValue))
                            }
                        }
                        
                        let rafReferralCouponGenerationAnalyticsEvent = RafReferralCouponGenerationAnalyticsEvent(referralCodeGenerationSucceeded: referralCodeGenerationSucceeded)
                        Copilot.instance.report.log(event: rafReferralCouponGenerationAnalyticsEvent)
                    }
                    }.startExecution()
            }
        }
    }
    
    private func updateLogicModules(byRafData rafData: RafData) -> [RafCellLogicModule] {
        var logicModules = [RafCellLogicModule]()
        if rafData.isAltruisticProgram {
            let isActiveRewardsEmpty = rafData.rewards.filter({ $0.status == .active}).isEmpty
            if !rafData.discountCodes.isEmpty || !isActiveRewardsEmpty {
                logicModules.append(RewardsLogicModule(isAltruistic: rafData.isAltruisticProgram, rewards: rafData.rewards, termsOfUseUrl: rafData.staticData.termsOfUseUrl))
                logicModules.append(DiscountCodesLogicModule(discountCodes: rafData.discountCodes))
                logicModules.append(WaveLogicModule())
                if let dynamicData = rafData.dynamicData {
                    logicModules.append(DynamicDataLogicModule(dynamicData: dynamicData))
                }
                logicModules.append(AltruisticShareLogicModule(altruisticProgram: rafData.altruisticProgram))
                logicModules.append(RafFooterLogicModule(staticData: rafData.staticData))
            }
            else {
                ZLogManagerWrapper.sharedInstance.logInfo(message: "Altruistic with no raf program")
            }
            
        } else {
            guard let rafProgram = rafData.rafProgram else {
                ZLogManagerWrapper.sharedInstance.logInfo(message: "Not Altruistic with no raf program")
                return logicModules
            }
            
            logicModules.append(RafHeaderLogicModule(rafProgram: rafProgram))
            logicModules.append(RewardsLogicModule(isAltruistic: rafData.isAltruisticProgram, rafProgram: rafProgram, rewards: rafData.rewards, termsOfUseUrl: rafData.staticData.termsOfUseUrl))
            logicModules.append(DiscountCodesLogicModule(discountCodes: rafData.discountCodes))
        
            if let dynamicData = rafData.dynamicData {
                logicModules.append(WaveLogicModule())
                logicModules.append(DynamicDataLogicModule(dynamicData: dynamicData))
            }
            logicModules.append(RafFooterLogicModule(staticData: rafData.staticData))
        }
        
        return logicModules
    }
    
}

extension RafDataViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logicModules.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var generalCell = UITableViewCell()
        
        let logicModule = self.logicModules[indexPath.row]
        logicModule.delegate = self
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: logicModule.cellIdentifier, for: indexPath) as? RafTableViewCell {
            cell.setup(logicModule: logicModule, delegate: self)
            generalCell = cell
        }
        
        return generalCell
    }
    
}

extension RafDataViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let logicModule = self.logicModules[indexPath.row]
        return logicModule.getEstimatedCellHeight()
    }
}

extension RafDataViewController: RafCellLogicModuleDelegate {
    
    func cellLogicModuleCellForLogicModule(logicModule: RafCellLogicModule) -> UITableViewCell? {
        var rafCell: RafTableViewCell?
        if let row = self.logicModules.firstIndex(of: logicModule) {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = self.tableView.cellForRow(at: indexPath) as? RafTableViewCell {
                rafCell = cell
            }
        }
        return rafCell
    }
    
}

extension RafDataViewController: RewardsTableViewCellDelegate {
    
    func getDiscountButtonPressed(withValue value: String?, selectedRewardsSum: SelectedRewardsSum?, rewardsIds: [String]) {
        guard let rafData = self.rafData else {
            return
        }
        let getDiscountAlert = AppAlert.discountCode(value: value, storeName: rafData.staticData.storeName)
        
        presentAlertControllerWithPopupRepresentable(getDiscountAlert, cancelButtonText: LocalizationHelper.translatedStringForKey(key: Strings.Raf.cancel.rawValue), actionButtonText: LocalizationHelper.translatedStringForKey(key: Strings.Raf.getTheCode.rawValue), cancelCompletionHandler: {
            Copilot.instance.report.log(event: RafTapGetDiscountCancelAnalyticsEvent())
        }) {
            [weak self] in
            
            let rafTapGetDiscountConfirmAnalyticsEvent = RafTapGetDiscountConfirmAnalyticsEvent(rewardAggregatedValue: selectedRewardsSum?.sum, rewardAggregatedCurrencyCode: selectedRewardsSum?.currency)
            Copilot.instance.report.log(event: rafTapGetDiscountConfirmAnalyticsEvent)
            
            self?.showLoadingView()
            
            self?.claimCreditWorker =
                Copilot.instance.referAFriend.getClaimRewardWorker(withRewardsIds: rewardsIds, { (response) in
                    self?.hideLoadingView() { [weak self] in
                        let couponCodeGenerationSucceeded: Bool
                        switch response {
                        case .success(let rafData):
                            couponCodeGenerationSucceeded = true
                            self?.rafData = rafData
                            if let logicModules = self?.updateLogicModules(byRafData: rafData) {
                                self?.logicModules = logicModules
                                self?.tableView.reloadData()
                            }
                            
                        case .failure(let error):
                            couponCodeGenerationSucceeded = false
                            
                            switch error {
                            case .requiresRelogin(_):
                                self?.delegate?.failedOnUnauthorized()
                                
                            case .generalError(_):
                                let generalErrorAlert = AppAlert.generalError
                                self?.presentAlertControllerWithPopupRepresentable(generalErrorAlert, cancelButtonText: LocalizationHelper.translatedStringForKey(key: Strings.Raf.cancel.rawValue))
                                
                            case .connectivityError(_):
                                let connectivityErrorAlert = AppAlert.connectivityError
                                self?.presentAlertControllerWithPopupRepresentable(connectivityErrorAlert, cancelButtonText: LocalizationHelper.translatedStringForKey(key: Strings.Raf.cancel.rawValue))
                            }
                        }
                        
                        let rafRewardCouponGenerationAnalyticsEvent = RafRewardCouponGenerationAnalyticsEvent(couponCodeGenerationSucceeded: couponCodeGenerationSucceeded)
                        Copilot.instance.report.log(event: rafRewardCouponGenerationAnalyticsEvent)
                    }
                }).startExecution()
        }
    }
    
    func termsApplyButtonPressed() {
        guard let rafData = self.rafData, let termsOfUseUrl = rafData.staticData.termsOfUseUrl, let url = URL(string: termsOfUseUrl) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

