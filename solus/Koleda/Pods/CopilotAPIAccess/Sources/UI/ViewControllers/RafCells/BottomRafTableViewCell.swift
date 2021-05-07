//
//  BottomRafTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class BottomRafTableViewCell: RafTableViewCell {

    //MARK: - Properties
    
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var termsAndConditionsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        termsAndConditionsButton.underline()
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
        let rafTapTermsAndConditionsAnalyticsEvent = RafTapTermsAndConditionsAnalyticsEvent(termsLocation: .footer)
        Copilot.instance.report.log(event: rafTapTermsAndConditionsAnalyticsEvent)
        
        guard let logicModule = logicModule as? RafFooterLogicModule,
            let termsURLString = logicModule.termsURLString,
            let url = URL(string: termsURLString) else {
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    override func setup(logicModule: RafCellLogicModule, delegate: RafTableViewCellDelegate?) {
        super.setup(logicModule: logicModule)
        
        if let logicModule = logicModule as? RafFooterLogicModule {
            Label.text = logicModule.rafCompanyDetailsString
            termsAndConditionsButton.isHidden = logicModule.termsURLString == nil
        }
    }
    
}
