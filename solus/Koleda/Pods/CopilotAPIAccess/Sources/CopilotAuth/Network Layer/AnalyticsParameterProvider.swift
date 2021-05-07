//
//  AnalyticsParameterProvider.swift
//  CopilotAuth
//
//  Created by Yulia Felberg on 03/10/2017.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
import UIKit

struct AnalyticsParameterProvider {
    
    private struct Keys {
        static let deviceId = "deviceId"
        static let osType = "osType"
        static let deviceType = "deviceType"
        static let deviceModel = "deviceModel"
        static let osVersion = "osVersion"
        static let appVersion = "applicationVersion"
        static let timeZone = "timezone"
        
        struct TimeZoneKeys{
            static let currentTimeInClientInMilliseconds = "currentTimeInClientInMilliseconds"
            static let offsetFromUTCInMilliseconds = "offsetFromUTCInMilliseconds"
            static let timeZoneId = "timeZoneId"
        }
    }
    
    private struct Parameters {
        static let naDeviceId = "N/A"
        static let deviceTypePhone = "PHONE"
        static let osType = "IOS"
    }
    
    static let kAnalyticsParametersDeviceDetails: [String : Any] = [
        Keys.osType : Parameters.osType,
        Keys.deviceModel: ZDeviceModel.getDeviceType(),
        Keys.osVersion: UIDevice.current.systemVersion,
        Keys.deviceId: (UIDevice.current.identifierForVendor?.uuidString ?? Parameters.naDeviceId),
        Keys.appVersion: (Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""),
        Keys.deviceType: Parameters.deviceTypePhone,
        Keys.timeZone: AnalyticsParameterProvider.getExtendedTimezone()
    ]
    
    static private func getExtendedTimezone() -> [String: Any] {
        var extendedTimezoneDetails = [String:Any]()
        
        let timezone = TimeZone.current
        let offsetTimeInMillis : Int64 = Int64(timezone.secondsFromGMT() * 1000)
        var offset : Int64 = offsetTimeInMillis
        if (timezone.isDaylightSavingTime()) {
            offset = offset - (Int64)(timezone.daylightSavingTimeOffset() * 1000)
        }
        
        extendedTimezoneDetails[Keys.TimeZoneKeys.currentTimeInClientInMilliseconds] = Int64(Date().timeIntervalSince1970 * 1000)
        extendedTimezoneDetails[Keys.TimeZoneKeys.offsetFromUTCInMilliseconds] = offset
        extendedTimezoneDetails[Keys.TimeZoneKeys.timeZoneId] = timezone.identifier
        
        return extendedTimezoneDetails
    }
}
