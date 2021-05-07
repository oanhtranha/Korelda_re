//
//  CtaTypeMapper.swift
//  TestParsing
//
//  Created by Elad on 28/01/2020.
//  Copyright © 2020 Elad. All rights reserved.
//

import Foundation

struct CtaTypeMapper {
    
    private enum CtaTypes: String {
        case buttonCta = "ButtonCta"
        case htmlCta = "HtmlCta"
    }
    
    //MARK: - Consts
    private struct Keys {
        static let type = "_type"
    }
    
    //MARK: - Factory
    static func map(withDictionary dictionary: [String: Any]) -> CtaType? {
        let typeResponse = dictionary[Keys.type] as? String
        var type: CtaType?
          switch typeResponse {
          case CtaTypes.buttonCta.rawValue:
            type = CtaButtonType(withDictionary: dictionary)
          case CtaTypes.htmlCta.rawValue:
              type = CtaHtmlType(withDictionary: dictionary)
          default:
              type = nil
          }
        return type
    }
}
