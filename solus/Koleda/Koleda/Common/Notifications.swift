//
//  Notifications.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

extension NSNotification.Name {
    static let KLDNotConnectedToInternet = NSNotification.Name("KLDNotConnectedToInternet")
    static let KLDDidChangeRooms = NSNotification.Name("KLDDidChangeRooms")
    static let KLDNeedUpdateSelectedRoom = NSNotification.Name("KLDNeedUpdateSelectedRoom")
    static let KLDDidChangeWifi = NSNotification.Name("KLDDidChangeWifi")
    static let KLDNeedToReSearchDevices = NSNotification.Name("KLDNeedToReSearchDevices")
    static let KLDNeedToUpdateSchedules = NSNotification.Name("KLDNeedToUpdateSchedules")
    static let KLDDidUpdateTemperatureModes = NSNotification.Name("KLDDidUpdateTemperatureModes")
    static let KLDNeedReLoadModes = NSNotification.Name("KLDNeedReLoadModes")
}
