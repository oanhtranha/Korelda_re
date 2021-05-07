//
//  SignUpManager.swift
//  Koleda
//
//  Created by Oanh tran on 6/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol SignUpManager {
    func signUp(name: String, email: String, password: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func resetPassword(email: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
}


class SignUpManagerImpl: SignUpManager {
    
    private let sessionManager: Session
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    init(sessionManager: Session) {
        self.sessionManager =  sessionManager
    }
    
    func signUp(name: String, email: String, password: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        let timezone = TimeZone.current.identifier
        let params = ["name": name,
                      "email": email,
                      "password": password,
                      "zoneId": timezone]
        guard let request = URLRequest.postRequestWithJsonBody(url: baseURL().appendingPathComponent("auth/signup"), parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        
        AF.request(request).validate().response { response in
            if let error = response.error {
                if let error = error as? AFError, error.responseCode == 400 {
                    failure(WSError.emailExisted)
                } else {
                    failure(WSError.general)
                }
            } else {
                success()
            }
        }
    }
    
    func resetPassword(email: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let endpoint = "auth/reset-password?email=\(email)"
        guard let url = URL(string: baseURL().absoluteString + endpoint) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        guard let request = try? URLRequest(url: url, method: .post) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure(WSError.general)
            }
            return
        }
        
        AF.request(request).validate().response { response in
            if let error = response.error {
                if let error = error as? AFError, error.responseCode == 404 {
                    failure(WSError.userNotFound)
                } else {
                    failure(WSError.general)
                }
            } else {
                success()
            }
        }
    }
}
