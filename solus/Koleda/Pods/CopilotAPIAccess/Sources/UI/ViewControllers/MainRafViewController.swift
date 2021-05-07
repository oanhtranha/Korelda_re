//
//  ReferAFriendViewController.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit
import CopilotLogger

public class ReferAFriendViewController: UIViewController {

    //MARK: - Properties
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorDesctiption: UILabel!
    
    public weak var delegate: ReferAFriendViewControllerDelegate?
    
    var couponWorker: RafPollingWorker<GenerateReferralCouponError>?
    var recoveryWorker: JobsRecoveryWorker?
    
    //MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRafData(shouldIgnorePendingJobs: false)
    }
    
    @IBAction func retryButtonPressed(_ sender: Any) {
        errorView.isHidden = true
        fetchRafData(shouldIgnorePendingJobs: false)
    }
    
    //MARK: - Private functions
    
    private func fetchRafData(shouldIgnorePendingJobs: Bool) {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "Getting updated RafData")
        if !shouldIgnorePendingJobs {
            activityIndicator.startAnimating()
        }
    
        Copilot.instance.referAFriend.fetchRafData().build().execute { [weak self] (response) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async(execute:
                {
                    if !shouldIgnorePendingJobs {
                        strongSelf.activityIndicator.stopAnimating()
                    }
                    
                    switch response {
                    case .success(let rafData):
                        ZLogManagerWrapper.sharedInstance.logInfo(message: "Success fetch raf data")
                        
                        strongSelf.updateUI(byRafData: rafData)
                        
                        if rafData.pendingJobs.count != 0 {
                            if !shouldIgnorePendingJobs {
                                ZLogManagerWrapper.sharedInstance.logInfo(message: "Handling pending jobs found in RafData. Will recover \(rafData.pendingJobs.count) pending jobs")
                                strongSelf.handlePendingJobs(rafData.pendingJobs)
                            } else {
                                ZLogManagerWrapper.sharedInstance.logInfo(message: "Found \(rafData.pendingJobs.count) pending jobs - but will be ignored")
                                strongSelf.hideLoadingView()
                            }
                        } else {
                            ZLogManagerWrapper.sharedInstance.logInfo(message: "No pending jobs to handle")
                        }
                        
                    case .failure(error: let error):
                        ZLogManagerWrapper.sharedInstance.logInfo(message: "Failed fetch raf data")
                        
                        switch error {
                        case .requiresRelogin(let debugMessage):
                            ZLogManagerWrapper.sharedInstance.logError(message: "Requires relogin when trying to fetch raf data - ֿ\(debugMessage)")
                            strongSelf.delegate?.referAFriendViewControllerDidUnauthorize(strongSelf)
                            
                        case .generalError(let debugMessage):
                            ZLogManagerWrapper.sharedInstance.logError(message: "Raf connectivity when trying to fetch raf data - ֿ\(debugMessage)")
                            strongSelf.errorDesctiption.text = LocalizationHelper.translatedStringForKey(key: Strings.Raf.generalError.rawValue)
                            strongSelf.errorView.isHidden = false
                            
                        case .connectivityError(let debugMessage):
                            ZLogManagerWrapper.sharedInstance.logError(message: "Raf general error when trying to fetch raf data - ֿ\(debugMessage)")
                            
                            strongSelf.errorDesctiption.text = LocalizationHelper.translatedStringForKey(key: Strings.Raf.noInternetConnection.rawValue)
                            strongSelf.errorView.isHidden = false
                            
                        }
                    }
            })
        }
    }
    
    private func updateUI(byRafData rafData: RafData) {
        var childVC: UIViewController?
        
        let isActiveRewardsEmpty = rafData.rewards.filter({ $0.status == .active}).isEmpty
        if rafData.isAltruisticProgram && rafData.discountCodes.isEmpty && isActiveRewardsEmpty {
            if let altruisticVC = CopilotViewControllersFactory.createControllerWithType(.altruistic) as? AltruisticViewController {
                altruisticVC.altruisticProgram = rafData.altruisticProgram
                
                childVC = altruisticVC
            }
        } else {
            if let rafDataVC = CopilotViewControllersFactory.createControllerWithType(.rafData) as? RafDataViewController {
                rafDataVC.rafData = rafData
                
                childVC = rafDataVC
            }
        }
        
        if let childVC = childVC {
            DispatchQueue.main.async {
                childVC.willMove(toParent: self)
                childVC.view.alpha = 0
                self.view.addSubview(childVC.view)
                childVC.view.translatesAutoresizingMaskIntoConstraints = false
                childVC.view.addConstraintsToSizeToParent()
                self.addChild(childVC)
                childVC.didMove(toParent: self)
                
                UIView.transition(with: childVC.view, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                    childVC.view.alpha = 1
                })
            }
        }
    }
    
    private func handlePendingJobs(_ pendingJobs: [RafJob]) {
        showLoadingView()
        if !pendingJobs.isEmpty {
            recoveryWorker = Copilot.instance.referAFriend.getPendingJobsRecoveryWorker(withPendingRafJobs: pendingJobs) { [weak self] (shouldRefreshData) in
                if shouldRefreshData {
                    self?.fetchRafData(shouldIgnorePendingJobs: true)
                } else {
                    self?.hideLoadingView()
                }
            }.startExecution()
        }
    }
    
    //MARK: - Public functions
    
    public func refreshData() {
        fetchRafData(shouldIgnorePendingJobs: false)
    }

}

extension ReferAFriendViewController: RafDataViewControllerDelegate {
    
    func failedOnUnauthorized() {
        delegate?.referAFriendViewControllerDidUnauthorize(self)
    }
    
    func rafDataUpdated() {
        //TODO: Handle with program changing
    }
}
