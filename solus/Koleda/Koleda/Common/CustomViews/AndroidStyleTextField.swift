//
//  AndroidStyleTextField.swift
//  Koleda
//
//  Created by Oanh tran on 5/28/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit

@IBDesignable
class AndroidStyleTextField: UnderlineTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        lineColor = .app_contentColor
        selectedLineColor = .app_titleColor
        titleColor = .app_titleColor
        selectedTitleColor = .app_titleColor
        lineHeight = 0.5
        selectedLineHeight = 1
        font = UIFont.app_FuturaPTBook(ofSize: 14)
        titleFont = UIFont.app_FuturaPTDemi(ofSize: 13)
        titleToTextFieldSpacing = 5
        lineToTextFieldSpacing = 5
        textColor = .app_titleColor
    }
}

@IBDesignable
class AndroidStyle2TextField: UnderlineTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        lineColor = UIColor.clear
        titleColor = UIColor.white
        selectedTitleColor = UIColor.white
        lineHeight = 1
        selectedLineHeight = 1
        font = UIFont.SFProDisplayRegular17
        titleFont = UIFont.SFProDisplaySemibold10
        titleToTextFieldSpacing = 5
        lineToTextFieldSpacing = 5
        textColor = UIColor.hexB5B5B5
        setNeedsLayout()
        layoutIfNeeded()
    }
}

@IBDesignable
class AndroidStyle3TextField: UnderlineTextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        lineColor = UIColor.clear
        titleColor = UIColor.black
        selectedTitleColor = UIColor.black
        lineHeight = 1
        selectedLineHeight = 1
        font = UIFont.SFProDisplayRegular17
        titleFont = UIFont.SFProDisplaySemibold14
        titleToTextFieldSpacing = 5
        lineToTextFieldSpacing = 5
        textColor = UIColor.hexB5B5B5
        setNeedsLayout()
        layoutIfNeeded()
    }
}
