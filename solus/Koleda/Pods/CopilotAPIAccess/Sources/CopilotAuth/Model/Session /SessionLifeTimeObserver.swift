//
//  SessionLifeTimeNotifyer.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol SessionLifeTimeObserver: class {
    func sessionStarted(_ userId: String?)
    func sessionEnded()
}

//Override default value with extension
extension SessionLifeTimeObserver {
    func sessionStarted() {
        sessionStarted(nil)
    }
}

