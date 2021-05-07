//
//  UITextField+Extensions.swift
//  Koleda
//
//  Created by Oanh tran on 8/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func addInputAccessoryView(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        barButton.tintColor = .black
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
    
    @IBInspectable var placeholderColor : UIColor {
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue])
        }
        get {
            return UIColor.clear
        }
    }
}
