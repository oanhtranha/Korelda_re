//
//  InAppMessagesDelegate.swift
//  CopilotAPIAccess
//
//  Created by Elad on 25/05/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

public protocol InAppMessagesDelegate: class {
    func handleDeeplink(_ deeplink: String) -> Bool
}
