//
//  InAppManagerAPIAccess.swift
//  CopilotAPIAccess
//
//  Created by Elad on 14/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

public protocol InAppManagerAPIAccess {
    func enable()
    func disable()
    func setDelegate(_ delegate: InAppMessagesDelegate)
}

