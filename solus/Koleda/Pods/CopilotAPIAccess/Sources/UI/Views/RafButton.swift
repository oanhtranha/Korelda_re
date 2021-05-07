//
//  RafButton.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 10/12/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class RafButton: UIButton {

    @IBInspectable var localizeKey: String {
        set {
            let text = NSLocalizedString(newValue, bundle: Bundle(for: Copilot.self), comment:"");
            setTitle(text, for: .normal)
        }
        get {
            return ""
        }
    }
}
