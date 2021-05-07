//
//  AppConstants.swift
//  Koleda
//
//  Created by Oanh tran on 5/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

struct AppConstants {
    static let introVideoLink  = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
    static let privacyPolicyLink  = "https://www.websitepolicies.com/policies/view/VfoiBcKV"
    static let legalPrivacyPolicyLink  = "https://www.websitepolicies.com/policies/view/YnPlPCKN"
    static let legalTermAndConditionLink  = "https://www.websitepolicies.com/policies/view/RiQksFCY"
    static let defaultShellyHostLink = "http://192.168.33.1:80"
    static let supportEmail = "help@koleda.co"
}

struct Constants {
    static let passwordMinLength = 6
    static let passwordMaxLength = 21
    static let nameMaxLength = 50
    static let MAX_END_TIME_POINT = 36000
    static let DEFAULT_BOOSTING_END_TIME_POINT = 5400
    static let MIN_TEMPERATURE: Double = 0
    static let MAX_TEMPERATURE: Double = 40
    static let DEFAULT_TEMPERATURE: Double = 20.5
    static let MIN_TEMPERATURE_MODE: Int = 0
    static let MAX_TEMPERATURE_MODE: Int = 25

    static let MAX_TIME_DAY: Int = 1440
}
