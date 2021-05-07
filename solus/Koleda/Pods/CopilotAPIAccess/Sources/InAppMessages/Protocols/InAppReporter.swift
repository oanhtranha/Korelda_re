//
//  InAppReporter.swift
//  CopilotAPIAccess
//
//  Created by Elad on 12/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol InAppReporter {
    func reportMessageTriggered(generalParameters : [String : String])
    func reportMessageDisplayed(generalParameters : [String : String])
    func reportMessageCtaClicked(generalParameters : [String : String], ctaReportParam: String?)
}
