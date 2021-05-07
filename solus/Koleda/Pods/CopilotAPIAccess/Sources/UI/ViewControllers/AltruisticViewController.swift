//
//  AltruisticViewController.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 10/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class AltruisticViewController: UIViewController {

    var altruisticProgram: AltruisticProgram?
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rafScreenLoadAnalyticsEvent = RafScreenLoadAnalyticsEvent(programType: .altruistic, hasBalance: false)
        Copilot.instance.report.log(event: rafScreenLoadAnalyticsEvent)
        
        setupUI()
    }
    
    private func setupUI() {
        if let altruisticProgram = altruisticProgram {
            descriptionLabel.text = altruisticProgram.description
        }
    }

    @IBAction func shareButtonPressed(_ sender: Any) {
        let rafTapShareReferralCouponAnalyticsEvent = RafTapShareReferralCouponAnalyticsEvent(programType: .altruistic)
        Copilot.instance.report.log(event: rafTapShareReferralCouponAnalyticsEvent)
        
        if let altruisticProgram = altruisticProgram {
            self.shareText(altruisticProgram.shareText)
        }
    }
}
