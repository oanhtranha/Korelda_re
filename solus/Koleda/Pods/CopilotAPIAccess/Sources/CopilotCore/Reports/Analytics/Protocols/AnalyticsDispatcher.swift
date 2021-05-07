//
//  AnalyticsDispatcher.swift
//  AOTCore
//
//  Created by Tom Milberg on 09/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public protocol AnalyticsDispatcher {
    func dispatcherLogCustomEvent(event: AnalyticsEvent)
}
