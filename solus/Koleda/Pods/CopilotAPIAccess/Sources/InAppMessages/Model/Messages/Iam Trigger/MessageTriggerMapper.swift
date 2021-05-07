//
//  MessageTriggerMapper.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

struct MessageTriggerMapper {
    
    private enum TriggerType: String {
        //The case value need to be exact name like we recieved from the server
        case oneOfEventTrigger = "OneOfEventTrigger"
        case noEventTrigger = "NoEventTrigger"
    }
    
    //MARK: - Consts
    private struct Keys {
        static let type = "_type"
    }
    
    //MARK: - Factory
    static func map(withDictionary dictionary: [String: Any]) -> InAppMessageTrigger? {
        let typeResponse = dictionary[Keys.type] as? String
        var type: InAppMessageTrigger?
          switch typeResponse {
          case TriggerType.oneOfEventTrigger.rawValue:
            type = OneOfEventTrigger(withDictionary: dictionary)
          case TriggerType.noEventTrigger.rawValue:
              type = NoEventTrigger()
          default:
              type = nil
          }
        return type
    }
}
