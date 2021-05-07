//
//  AnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 09/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public protocol AnalyticsEvent {
    var customParams: Dictionary<String, String> { get }
    var eventName: String { get }
    var eventOrigin: AnalyticsEventOrigin { get }
    var eventGroups: [AnalyticsEventGroup] { get }
}
