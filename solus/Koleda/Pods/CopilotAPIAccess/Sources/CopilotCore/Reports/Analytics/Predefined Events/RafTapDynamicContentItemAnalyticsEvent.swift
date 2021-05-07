//
//  RafTapDynamicContentItemAnalyticsEvent.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 15/09/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

public struct RafTapDynamicContentItemAnalyticsEvent: AnalyticsEvent {
    
    private let name = "raf_tap_dynamic_content_item"
    private let dynamicItemTitleParamKey: String = "dynamic_item_title"
    private let dynamicItemActionUrlParamKey: String = "dynamic_item_action_url"
    private let dynamicItemPositionParamKey: String = "dynamic_item_position"
    
    private let dynamicItemTitle: String
    private let dynamicItemActionUrl: String?
    private let dynamicItemPosition: Int
    
    public init(dynamicItemTitle: String, dynamicItemActionUrl: String?, dynamicItemPosition: Int) {
        self.dynamicItemTitle = dynamicItemTitle
        self.dynamicItemActionUrl = dynamicItemActionUrl
        self.dynamicItemPosition = dynamicItemPosition
    }
    
    public var customParams: Dictionary<String, String> {
        var params = [dynamicItemTitleParamKey : dynamicItemTitle, dynamicItemPositionParamKey : String(dynamicItemPosition)]
        
        if let dynamicItemActionUrl = dynamicItemActionUrl {
            params[dynamicItemActionUrlParamKey] = dynamicItemActionUrl
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
