//
//  NpsInappModel.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/05/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation


struct NpsInappPresentationModel {
    
    //MARK: - Consts
    private struct Keys {
        static let ctaBackgroundColorHex = "ctaBackgroundColorHex"
        static let ctaTextColorHex = "ctaTextColorHex"
        static let labelQuestionText = "labelQuestionText"
        static let labelNotLikely = "labelNotLikely"
        static let labelExtremelyLikely = "labelExtremelyLikely"
        static let labelAskMeAnotherTime = "labelAskMeAnotherTime"
        static let labelThankYou = "labelThankYou"
        static let labelDone = "labelDone"
        static let backgroundColorHex = "backgroundColorHex"
        static let textColorHex = "textColorHex"
        static let imageUrl = "imageUrl"
    }
    
    //MARK: - Properties
    let ctaBackgroundColorHex: String
    let ctaTextColorHex: String
    let labelQuestionText: String
    let labelNotLikely: String
    let labelExtremelyLikely: String
    let labelAskMeAnotherTime: String
    let labelThankYou: String
    let labelDone: String
    let backgroundColorHex: String
    let textColorHex: String

    let imageUrl: String?
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard
            let ctaBackgroundColorHex = dictionary[Keys.ctaBackgroundColorHex] as? String,
            let ctaTextColorHex = dictionary[Keys.ctaTextColorHex] as? String,
            let labelQuestionText = dictionary[Keys.labelQuestionText] as? String,
            let labelNotLikely = dictionary[Keys.labelNotLikely] as? String,
            let labelExtremelyLikely = dictionary[Keys.labelExtremelyLikely] as? String,
            let labelAskMeAnotherTime = dictionary[Keys.labelAskMeAnotherTime] as? String,
            let labelThankYou = dictionary[Keys.labelThankYou] as? String,
            let labelDone = dictionary[Keys.labelDone] as? String,
            let backgroundColorHex = dictionary[Keys.backgroundColorHex] as? String,
            let textColorHex = dictionary[Keys.textColorHex] as? String
            else { return nil }
        
        self.ctaBackgroundColorHex = ctaBackgroundColorHex
        self.ctaTextColorHex = ctaTextColorHex
        self.labelQuestionText = labelQuestionText
        self.labelNotLikely = labelNotLikely
        self.labelExtremelyLikely = labelExtremelyLikely
        self.labelAskMeAnotherTime = labelAskMeAnotherTime
        self.labelThankYou = labelThankYou
        self.labelDone = labelDone
        self.backgroundColorHex = backgroundColorHex
        self.textColorHex = textColorHex
        
        if let imageUrl = dictionary[Keys.imageUrl] as? String { self.imageUrl = imageUrl } else { self.imageUrl = nil }
    }
}

extension NpsInappPresentationModel: InAppMessagePresentation {
    var renderer: Renderer { NpsInappRenderer(presentationModel: self) }
}


