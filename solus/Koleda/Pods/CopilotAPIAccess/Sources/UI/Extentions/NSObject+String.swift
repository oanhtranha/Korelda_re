//
//  NSObject+String.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 11/08/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

internal extension NSObject {
    class func stringFromClass() -> String {
        return String(describing: self)
    }
}
