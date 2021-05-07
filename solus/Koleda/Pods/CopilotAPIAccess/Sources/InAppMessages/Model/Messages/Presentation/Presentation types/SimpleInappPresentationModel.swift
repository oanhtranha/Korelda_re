//
//  SimpleInappPresentationModel.swift
//  CopilotAPIAccess
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation


struct SimpleInappPresentationModel {
    
    //MARK: - Consts
    private struct Keys {
        static let title = "title"
        static let body = "body"
        static let imageUrl = "imageUrl"
        static let ctas = "ctas"
        static let bgColorHex = "backgroundColorHex"
        static let titleColorHex = "textColorHex"
        static let bodyColorHex = "bodyColorHex"
    }
    
    //MARK: - Properties
    let title: String
    let imageUrl: String?
    let bodyText: String?
    let bgColor: String?
    let titleColor: String?
    let bodyColor: String?
    let ctas: [CtaType?]
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let title = dictionary[Keys.title] as? String,
            let ctasArr = dictionary[Keys.ctas] as? [[String : AnyObject]], 1...3 ~= ctasArr.count  else { return nil }
        
        var ctasFromJson: [CtaType?] = []
        ctasArr.forEach { ctasFromJson.append(CtaTypeMapper.map(withDictionary: $0)) }
        if ctasFromJson.contains(where: {$0 == nil}) { return nil }
        ctas = ctasFromJson
        
        self.title = title

        if let body = dictionary[Keys.body] as? String { self.bodyText = body.trimmingCharacters(in: .whitespacesAndNewlines) } else { self.bodyText = nil }
        if let imageUrl = dictionary[Keys.imageUrl] as? String { self.imageUrl = imageUrl } else { self.imageUrl = nil }
        if let bgColor = dictionary[Keys.bgColorHex] as? String { self.bgColor = bgColor } else { self.bgColor = nil }
        if let titleColor = dictionary[Keys.titleColorHex] as? String { self.titleColor = titleColor } else { self.titleColor = nil }
        if let bodyColor = dictionary[Keys.bodyColorHex] as? String { self.bodyColor = bodyColor } else { self.bodyColor = nil }
    }
}

extension SimpleInappPresentationModel: InAppMessagePresentation {    
    var renderer: Renderer { SimpleInappRenderer(presentationModel: self) }
}
