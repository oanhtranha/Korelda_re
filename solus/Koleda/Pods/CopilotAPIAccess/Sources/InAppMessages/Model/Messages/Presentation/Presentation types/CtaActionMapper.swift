//
//  CtaAction.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

enum CtaActionType {
    
    case webNavigation(url: String)
    case appStoreRate
    case sendEmail(meilTo: String?, subject: String?, body: String?)
    case call(phoneNumber: String)
    case none
    case share(shareText: String?)
    case deeplink(deeplink: String)
    case externalLink(iosPackage:String?, linkIfPackageExist: String?, linkIfPackageDoesNotExist: String?)

    //The serverKey value need to be exact name like we recieved from the server
    var serverKey: String {
        switch self {
        case .webNavigation:
            return "WebNavigation"
        case .appStoreRate:
            return "AppStoreRate"
        case .sendEmail:
            return "SendEmail"
        case .call:
            return "Call"
        case .none:
            return "None"
        case .share:
            return "Share"
        case .deeplink:
            return "Deeplink"
        case .externalLink:
            return "ExternalLink"
        }
    }
}

struct CtaActionMapper {

    //MARK: - Consts
    private struct Keys {
        static let type = "_type"
    }

    //MARK: - Factory
    static func map(withDictionary dictionary: [String: Any]) -> CtaActionType? {
        let typeResponse = dictionary[Keys.type] as? String
        var type: CtaActionType?
        switch typeResponse {
        case CtaActionType.webNavigation(url: "").serverKey:
            if let webCtaType = WebNavigationCtaActionType(withDictionary: dictionary) {
                type = CtaActionType.webNavigation(url: webCtaType.url)
            }
        case CtaActionType.appStoreRate.serverKey:
            type = CtaActionType.appStoreRate
        case CtaActionType.sendEmail(meilTo: nil, subject: nil, body: nil).serverKey:
            let sendEmailtype = SendEmailCtaActionType(withDictionary: dictionary)
            type = CtaActionType.sendEmail(meilTo: sendEmailtype.mailTo, subject: sendEmailtype.subject, body: sendEmailtype.body)
        case CtaActionType.call(phoneNumber: "").serverKey:
            if let callActiontype = CallCtaActionType(withDictionary: dictionary) {
                type = CtaActionType.call(phoneNumber: callActiontype.phoneNumber)
            }
        case CtaActionType.none.serverKey:
            type = CtaActionType.none
        case CtaActionType.share(shareText: nil).serverKey:
            if let shareType = ShareCtaActionType(withDictionary: dictionary) {
                type = .share(shareText: shareType.text)
            }
        case CtaActionType.externalLink(iosPackage:"", linkIfPackageExist: "", linkIfPackageDoesNotExist: "").serverKey:
            if let openAnotherAppType = ExternalLinkCtaActionType(withDictionary: dictionary) {
                type = .externalLink(iosPackage: openAnotherAppType.iosObject?.identifier,
                                     linkIfPackageExist: openAnotherAppType.iosObject?.url,
                                     linkIfPackageDoesNotExist: openAnotherAppType.appUrl)
            }
        case CtaActionType.deeplink(deeplink: "").serverKey:
            if let deeplinkType = DeeplinkCtaActionType(withDictionary: dictionary) {
                type = CtaActionType.deeplink(deeplink: deeplinkType.deeplink)
            }
        default:
            ZLogManagerWrapper.sharedInstance.logError(message: "try to map unknown ctaType")
        }
        return type
    }
}
