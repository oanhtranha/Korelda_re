//
//  NpsInappRenderer.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/05/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import Kingfisher
import CopilotLogger

class NpsInappRenderer: BaseRenderer<NpsInappPresentationModel>, Renderer {

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

        getInAppImageIfExist { (image) in
            let popupDialog = PopupDialog(labelQuestionText: self.presentationModel.labelQuestionText,
                                          ctaBackgroundColor: self.presentationModel.ctaBackgroundColorHex,
                                          ctaTextColor: self.presentationModel.ctaTextColorHex,
                                          inAppDelegate: delegate,
                                          bgColor: self.presentationModel.backgroundColorHex,
                                          textColorHex: self.presentationModel.textColorHex,
                                          labelNotLikely: self.presentationModel.labelNotLikely,
                                          labelExtremelyLikely: self.presentationModel.labelExtremelyLikely,
                                          labelAskMeAnotherTime: self.presentationModel.labelAskMeAnotherTime,
                                          labelDone: self.presentationModel.labelDone,
                                          labelThankYou: self.presentationModel.labelThankYou,
                                          image: image) {
                                            ZLogManagerWrapper.sharedInstance.logInfo(message: "nps message dismissed")
            }

            popupDialog.npsSurveyCompletion = { (ctaNumber: String?) in
                if let ctaNumber = ctaNumber {
                    reporter.reportMessageCtaClicked(generalParameters: iamReport.parameters, ctaReportParam: "nps_answer=\(ctaNumber)")
                    ZLogManagerWrapper.sharedInstance.logInfo(message: "NPS survey - user choose \(ctaNumber)")
                } else {
                    ZLogManagerWrapper.sharedInstance.logInfo(message: "user dismissed the NPS survey message")
                }

            }

            popupDialog.show(animated: false) {
                ZLogManagerWrapper.sharedInstance.logInfo(message: "In App Message is presented successfully")
                completion(true)
            }
        }
    }

    private func getInAppImageIfExist(completion: @escaping ((UIImage?) -> ())) {
        guard let imageUrl = presentationModel.imageUrl, let validImageUrl = URL(string: imageUrl) else {
            completion(nil)
            return
        }
        KingfisherManager.shared.retrieveImage(with: validImageUrl) { (result) in
            switch result {
            case .failure(let error):
                completion(nil)
                ZLogManagerWrapper.sharedInstance.logError(message: "Can't download image because of error: \(error)")
            case .success(let value):
                completion(value.image)
            }
        }
    }
}
