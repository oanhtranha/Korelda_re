//
//  DiscountCodeTableViewCell.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

protocol DiscountCodeTableViewCellDelegate: class {
    func showCruton()
}

class DiscountCodeTableViewCell: UITableViewCell {

    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var copyButton: ButtonHighlight!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var discountCodeView: UIView!
    
    weak var delegate: DiscountCodeTableViewCellDelegate?
    
    private var value: Double? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        copyButton.delegate = self
        discountCodeView.roundLeftCorners(cornerRadius: 3)
    }
    
    func set(value: Double, currency: String, code: String) {
        self.value = value
        currencyLabel.text = currency + value.format(f: value.smartPercision)
        codeLabel.text = code
    }
    
    @IBAction func copyButtonPressed(_ sender: Any) {
        guard let code = codeLabel.text else {
            return
        }
        
        if let value = value {
            let rafTapCopyRewardCouponCodeAnalyticsEvent = RafTapCopyRewardCouponCodeAnalyticsEvent(rewardCouponDiscountValue: value, rewardCouponDiscountCurrencyCode: code)
            Copilot.instance.report.log(event: rafTapCopyRewardCouponCodeAnalyticsEvent)
        }
        
        UIPasteboard.general.string = code
        delegate?.showCruton()
    }

}

extension DiscountCodeTableViewCell: ButtonHighlightDelegate {
    
    func buttonShouldChangeAppearance(isHighlight: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.cellBackgroundView.backgroundColor = isHighlight ? .getDiscountHighlightedBackgroundColor : .getDiscountDefaultBackgroundColor
        }
    }
}
