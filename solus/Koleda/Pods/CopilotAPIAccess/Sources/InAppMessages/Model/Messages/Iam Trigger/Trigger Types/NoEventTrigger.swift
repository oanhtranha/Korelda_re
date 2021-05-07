//
//  NoEventTrigger.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct NoEventTrigger: InAppMessageTrigger {
    
    func analyticsEventLogged(_ analyticsEvent: AnalyticsEvent) -> Bool { return true }
    
    func getInitialState() -> InAppStatus { return .ready }
}

