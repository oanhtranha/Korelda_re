//
//  TapMenuItemAnalyticsEvent.swift
//  AOTCore
//
//  Created by Tom Milberg on 03/06/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public struct TapMenuItemAnalyticsEvent: AnalyticsEvent {
    
    var screenName: String?
    let menuItemValue: String
    
    let name = "tap_menu_item"
    let menuItemKey = "menu_item"
    
    public init(menuItem: String, screenName: String? = nil) {
        menuItemValue = menuItem
        self.screenName = screenName
    }
    
    //MARK: AnalyticsEvent

    public var customParams: Dictionary<String, String> {
        var params = [menuItemKey : menuItemValue]
        
        if let screenName = screenName {
            params.updateValue(screenName, forKey: AnalyticsConstants.screenNameKey)
        }
        
        return params
    }
    
    public var eventName: String {
        return name
    }
    
    public var eventOrigin: AnalyticsEventOrigin {
        return .User
    }
    
    public var eventGroups: [AnalyticsEventGroup] {
        return [.All]
    }
}
