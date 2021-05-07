//
//  AnalyticsEventsProviderProtocol.swift
//  AOTCore
//
//  Created by Tom Milberg on 10/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public protocol AnalyticsEventsProviderProtocol {
    func addEventLogProvider(newEventLogProvider: EventLogProvider)
    func removeEventLogProvider(eventLogProviderToRemove: EventLogProvider)
}
