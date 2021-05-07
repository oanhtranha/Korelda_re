//
//  UIButton+Appearance.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 18/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit
import CopilotLogger

internal extension UIButton {
    
    func underline() {
        guard let text = self.titleLabel?.text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: (text.count)))
        self.setAttributedTitle(attributedString, for: .normal)
    }
    
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        } else {
            ZLogManagerWrapper.sharedInstance.logError(message:"failed to receive CGContext")
        }
    }
}
