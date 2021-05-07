//
//  InAppReporterManager.swift
//  CopilotAPIAccess
//
//  Created by Elad on 12/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

enum InAppReporterSubEvent {
    case triggered
    case displayed
    case clicked(ctaReportParam: String?)
    
    var reportValue: String {
        switch self {
        case .triggered:
            return "in_app_triggered"
        case .displayed:
            return "in_app_displayed"
        case .clicked:
            return "in_app_clicked"
        }
    }
    
    var ctaReportParam: String? {
        switch self {
        case .displayed, .triggered:
            return nil
        case .clicked(let ctaReport):
            return ctaReport
        }
    }
}

class InAppReporterManager: InAppReporter {

    //MARK: - Properties
    typealias Dependencies = HasReporter
    private var dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func reportMessageTriggered(generalParameters: [String : String]) {
        dependencies.reporter.log(event: InAppAnalyticsEvent(subEvent: .triggered, generalParams: generalParameters))
    }
    
    func reportMessageDisplayed(generalParameters: [String : String]) {
        dependencies.reporter.log(event: InAppAnalyticsEvent(subEvent: .displayed, generalParams: generalParameters))
    }
    
    func reportMessageCtaClicked(generalParameters: [String : String], ctaReportParam: String?) {
        dependencies.reporter.log(event: InAppAnalyticsEvent(subEvent: .clicked(ctaReportParam: ctaReportParam), generalParams: generalParameters))
    }
}
