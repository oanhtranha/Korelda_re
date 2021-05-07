//
//  RafLocalizeLabel.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 10/12/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import UIKit

class RafLocalizeLabel: UILabel {

    @IBInspectable var localizeString:String {
        set {
            self.text = NSLocalizedString(newValue, bundle: Bundle.init(for: Copilot.self), comment:"")
        }
        get {
            return ""
        }
    }
}
