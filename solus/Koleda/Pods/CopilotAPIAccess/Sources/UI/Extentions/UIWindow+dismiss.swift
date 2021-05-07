//
//  UIWindow+dismiss.swift
//  CopilotAPIAccess
//
//  Created by Elad on 23/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

extension UIWindow {
    func dismiss() {
        isHidden = true

        if #available(iOS 13, *) {
            windowScene = nil
        }
    }
}
