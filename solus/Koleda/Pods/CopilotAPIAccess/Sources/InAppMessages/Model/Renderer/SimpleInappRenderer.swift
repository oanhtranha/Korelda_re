//
//  SimpleRenderer.swift
//  CopilotAPIAccess
//
//  Created by Elad on 10/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger
import Kingfisher

class SimpleInappRenderer: BaseRenderer<SimpleInappPresentationModel>, Renderer, DismissDelegate {
    
    private var popupDialog: PopupDialog?
    
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
        
        let bodyText = presentationModel.bodyText ?? ""
        
//        // Create the in app message popup

        var buttonAlignment: NSLayoutConstraint.Axis

        if UIDevice.current.orientation.isPortrait && presentationModel.ctas.count == 3 {
            buttonAlignment = .vertical
        } else {
            buttonAlignment = .horizontal
        }

        getInAppImageIfExist { (image) in
            
            self.popupDialog = PopupDialog(
                    title: self.presentationModel.title,
                    message: bodyText,
                    bgColor: self.presentationModel.bgColor,
                    titleColor: self.presentationModel.titleColor,
                    bodyColor: self.presentationModel.bodyColor,
                    image: image,
                    buttonAlignment: buttonAlignment,
                    preferredWidth: 330,
                    inAppDelegate: delegate,
                    dismissDelegate: self)
            
            
            self.presentationModel.ctas.forEach {[weak self] (ctaType) in
                if let cta = ctaType as? CtaButtonType {
                    let button = InAppButton(title: cta.text, textColor: UIColor(hexString: cta.textColorHex), bdColor: UIColor(hexString: cta.backgroundColorHex)) {
                        //cta clicked
                        reporter.reportMessageCtaClicked(generalParameters: iamReport.parameters, ctaReportParam: cta.report)
                        self?.popupDialog?.performAction(cta.action) {
                            ZLogManagerWrapper.sharedInstance.logInfo(message: "cta perform action completed")
                        }
                    }
                    self?.popupDialog?.addButton(button)
                } else {
                    ZLogManagerWrapper.sharedInstance.logError(message: "can't cast to ctaButtonType")
                }
            }
            self.popupDialog?.show(animated: false) {
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
    
    func dismissPoup() {
        self.popupDialog?.dismissPoup()
    }
}
