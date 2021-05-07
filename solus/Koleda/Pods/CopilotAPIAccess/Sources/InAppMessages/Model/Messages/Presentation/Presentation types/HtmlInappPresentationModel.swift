//
//  HtmlInappPresentationModel.swift
//  CopilotAPIAccess
//
//  Created by Elad on 29/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct HtmlInappPresentationModel {
    
    //MARK: - Consts
    private struct Keys {
        static let content = "content"
        static let ctas = "ctas"
    }
    
    //MARK: - Properties
        let content: String
        private(set) var ctas: [CtaHtmlType?] = []
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let content = dictionary[Keys.content] as? String else { return nil }
        
        self.content = content
        
        if let ctasArr = dictionary[Keys.ctas] as? [[String : AnyObject]] {
            var ctasArrFromJson: [CtaHtmlType?] = []
            ctasArr.forEach { ctasArrFromJson.append(CtaTypeMapper.map(withDictionary: $0) as? CtaHtmlType) }
            if ctasArrFromJson.contains(where: {$0 == nil}) { return nil }
            self.ctas = ctasArrFromJson
        }
    }
}

extension HtmlInappPresentationModel: InAppMessagePresentation {    
    var renderer: Renderer { HtmlInappRenderer(presentationModel: self) }
}
