//
//  OpenAnotherApplicationCtaActionType.swift
//  CopilotAPIAccess
//
//  Created by Elad on 20/05/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
/**
  *  "action": {
  *        "_type": "ExternalLink",
  *        "android": {                             // Not used in the iOS application
  *              "identifier":"com.abc.com",
  *              "url":"https://www.abc.com/android/contentId=1553"
  *         }
  *         "ios":{
  *              "identifier":"com.abc.com",
  *              "url":"https://www.abc.com/android/contentId=1553"
  *         }
  *         "originalUrl":"https://www.abc.com/android/contentId=1553",      // Not used in the application
  *         "appUrl":"https://www.abc.com/android/contentId=1553"
  *    }
  */
struct ExternalLinkCtaActionType: CtaAction {
    
    //MARK: - Consts
    private struct Keys {
        static let iosObject = "ios"
        static let appUrl = "appUrl"
    }
    
    //MARK: - Properties
    let iosObject: ApplicationPayload?
    let appUrl: String?
    
    // MARK: - Init
    init?(withDictionary dictionary: [String: Any]) {
        
        if dictionary[Keys.iosObject] == nil && dictionary[Keys.appUrl] == nil {
            return nil
        }
        if let appUrl = dictionary[Keys.appUrl] as? String, appUrl.isValidURL == true {
            self.appUrl = appUrl
        } else {
            self.appUrl = nil
        }
        if let iosObjectDict = dictionary[Keys.iosObject] as? [String: Any], let iosObject = ApplicationPayload(withDictionary: iosObjectDict){
            self.iosObject = iosObject
        } else {
            self.iosObject = nil
        }
    }
    
    struct ApplicationPayload {
        
        private struct Keys {
            static let identifier = "identifier"
            static let url = "url"
        }
        
        let identifier: String?
        let url: String?
        
        init?(withDictionary dictionary: [String: Any]) {
            if dictionary[Keys.identifier] == nil && dictionary[Keys.url] == nil {
                return nil
            }
            self.identifier = dictionary[Keys.identifier] as? String
            self.url = dictionary[Keys.url] as? String
          }
    }
}
