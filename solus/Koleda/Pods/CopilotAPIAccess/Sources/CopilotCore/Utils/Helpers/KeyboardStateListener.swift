//
//  KeyboardStateListener.swift
//  CopilotAPIAccess
//
//  Created by Elad on 10/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation


class KeyboardStateListener: NSObject {
    
    static let shared = KeyboardStateListener()
    
    private override init() { }
    
    private(set) var isVisible = false//check with michael, maybe true as default value is better

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(didShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    @objc private func didShow() {
        isVisible = true
    }

    @objc private func didHide() {
        isVisible = false
    }
}
