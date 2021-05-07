//
//  InAppMessages.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class InAppMessages {
    
    //MARK: - Consts
    private struct Keys {
        static let messages = "messages"
    }
    
    //MARK: - Properties
    let messages: [InAppMessage]
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        guard let messagesArr = dictionary[Keys.messages] as? [[String : AnyObject]] else { return nil }
        
        var messagesFromJson: [InAppMessage] = []
        messagesArr.forEach {
            if let message = InAppMessage(withDictionary: $0) {
                messagesFromJson.append(message)
            }
        }
        messages = messagesFromJson
    }
}
