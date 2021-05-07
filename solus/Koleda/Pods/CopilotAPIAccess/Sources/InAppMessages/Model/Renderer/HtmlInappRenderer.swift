//
//  HtmlRenderer.swift
//  CopilotAPIAccess
//
//  Created by Elad on 10/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

class HtmlInappRenderer: BaseRenderer<HtmlInappPresentationModel>, Renderer {
    
    func render(reporter: InAppReporter, iamReport: InAppMessageReport, delegate: InAppMessagesDelegate?, completion: @escaping (Bool) -> ()) {
        if verifyConditions() {
            showAlert(reporter: reporter, iamReport: iamReport, delegate: delegate) { completion($0) }
        }
        else {
            ZLogManagerWrapper.sharedInstance.logError(message: "can't verify conditions for display iam")
            completion(false)
        }
    }
    
    private func showAlert(reporter: InAppReporter, iamReport: InAppMessageReport, delegate: InAppMessagesDelegate?, completion: @escaping (Bool) -> ()) {
        
        let popupDialog = PopupDialog(htmlContent: presentationModel.content, inAppDelegate: delegate)
        
        self.presentationModel.ctas.forEach {(ctaHtmlType) in
            if let cta = ctaHtmlType {

                popupDialog.htmlButtons.append(cta)
                popupDialog.htmlCtaPressed = {
                    reporter.reportMessageCtaClicked(generalParameters: iamReport.parameters, ctaReportParam: cta.report)
                    ZLogManagerWrapper.sharedInstance.logInfo(message: "html button pressed")
                }
                popupDialog.htmlButtonCompletion = {
                    ZLogManagerWrapper.sharedInstance.logInfo(message: "html button action completed")
                }
            } else {
                ZLogManagerWrapper.sharedInstance.logError(message: "ctaHtmlType is nil")
            }
        }
        
        popupDialog.show(animated: false) {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "In App Message is presented successfully")
            completion(true)
        }
    }
}
