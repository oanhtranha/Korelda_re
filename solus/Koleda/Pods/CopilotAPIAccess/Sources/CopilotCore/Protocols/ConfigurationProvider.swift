//
//  ConfigurationProvider.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 30/10/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation

internal protocol ConfigurationProvider: class {
    var baseUrl: String? { get }
    var applicationId: String? { get }
    var isGdprCompliant: Bool? { get }
    var manageType: ManageType { get }
    var appVersion: String { get }
}
