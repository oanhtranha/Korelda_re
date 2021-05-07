//
//  InAppMessageTrigger.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 23/12/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

protocol InAppMessageTrigger {
    func analyticsEventLogged(_ analyticsEvent: AnalyticsEvent) -> Bool
    func getInitialState() -> InAppStatus
}
