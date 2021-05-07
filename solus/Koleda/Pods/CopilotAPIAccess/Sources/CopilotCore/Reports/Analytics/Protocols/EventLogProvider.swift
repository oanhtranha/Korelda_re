//
//  EventLogProvider.swift
//  AOTCore
//
//  Created by Tom Milberg on 08/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public protocol EventLogProvider: class {
    
    /// Enable events collection and reporting for this provider
    func enable()
    
    /// Disable events collection and reporting for this provider
    func disable()

    /// Sets the user id as user property (for supporting providers only)
    func setUserId(userId: String?)

    // TODO: Add a description here.
    func transformParameters(parameters: Dictionary<String, String>) -> Dictionary<String, String>
    
    /// Log either a Copilot predefined event or a any event that implements AnalyticEvent protocol providing the event name and additional parameters
    func logCustomEvent(eventName: String, transformedParams: Dictionary<String, String>)
    
    /// Name of the provider
    var providerName: String { get }
    
    /// Array of AnalyticsEventGroup which the provider is related with
    var providerEventGroups: [AnalyticsEventGroup] { get }
}
