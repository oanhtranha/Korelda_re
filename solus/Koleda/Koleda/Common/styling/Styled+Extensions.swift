//
//  Styled+Extensions.swift
//  Koleda
//
//  Created by Oanh Tran on 5/24/19.
//  Copyright © 2019 koleda. All rights reserved.
//
import UIKit

extension UIButton {
    func apply(_ style: Style.ViewStyle<UIButton>) {
        style.apply(to: self)
    }
}

extension UIView {
    func apply(_ style: Style.ViewStyle<UIView>) {
        style.apply(to: self)
    }
}

extension UIBarButtonItem {
    func apply(_ style: Koleda.Style.ViewStyle<UIBarButtonItem>) {
        style.apply(to: self)
    }
}

