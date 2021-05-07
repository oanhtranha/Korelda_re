//
//  UIButtonHighlight.swift
//  ZemingoBLELayer
//
//  Created by Revital Pisman on 19/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

protocol ButtonHighlightDelegate: class {
    func buttonShouldChangeAppearance(isHighlight: Bool)
}

class ButtonHighlight: UIButton {
    
    weak var delegate: ButtonHighlightDelegate?
    
    override var isHighlighted: Bool {
        didSet {
            delegate?.buttonShouldChangeAppearance(isHighlight: isHighlighted)
        }
    }
}
