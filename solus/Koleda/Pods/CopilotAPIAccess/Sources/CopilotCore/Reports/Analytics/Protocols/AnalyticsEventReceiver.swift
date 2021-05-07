//
//  AnalyticsEventReceiver.swift
//  CopilotAPIAccess
//
//  Created by Elad on 17/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol AnalyticsEventReceiver: class {
    func eventLogged(_ event: AnalyticsEvent)
}
