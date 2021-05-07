//
//  LoginAppManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginAppManager {
    
    var sessionManager: SessionManager
    
    var isLoggedIn: Bool {
        return UserDefaultsManager.loggedIn.enabled
    }
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    init() {
        let serverTrustPolicy = ServerTrustPolicy.pinCertificates(
            certificates: ServerTrustPolicy.certificates(),
            validateCertificateChain: true,
            validateHost: true
        )
        
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "10.10.1.80": serverTrustPolicy]
        sessionManager = SessionManager(configuration: URLSessionConfiguration.default,
                                        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        
        sessionManager.adapter = self
        sessionManager.retrier = self
    }
    
    func login(email: String, password: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        let params = ["email": email,
                      "password": password]
        let endPointURL = baseURL().appendingPathComponent("auth/login")
        guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                log.info("Successfully obtained access token")
                let json = JSON(result)
                let accessToken = json["accessToken"].stringValue
                let refreshToken = json["refreshToken"].stringValue
                let tokenType = json["tokenType"].stringValue
            
                do {
                    try LocalAccessToken.store(accessToken, tokenType: tokenType)
                    try RefreshToken.store(refreshToken)
                    
                    log.info("Successfully logged in")
                    success()
                } catch let error {
                    log.error("Failed to store LoginCredentials/Passcode/AccessToken in keychain - \(error.localizedDescription)")
                    failure(error)
                }
            case .failure(let error):
                log.error("Failed to obtain access token - \(error)")
                if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                    NotificationCenter.default.post(name: .AppNotConnectedToInternet, object: error)
                } else if let error = error as? AFError, error.responseCode == 400 {
                    failure(error)
                } else if let error = error as? AFError, error.responseCode == 401 {
                    failure(error)
                } else {
                    failure(error)
                }
            }
        }
    }
    
    func loginWithSocial(type: SocialType, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        guard let bundleID = Bundle.main.bundleIdentifier else {
            failure(RequestError.error(NSLocalizedString("failed to obtain bundle Identifier", comment: "")))
            return
        }
        
        let socialString = type == SocialType.facebook ? "facebook" : "google"
        
        let endPointURL = baseURL().appendingPathComponent("oauth2/authorize/\(socialString)?redirect_uri=\(bundleID)://oauth2/redirect")
        
        Alamofire.request(endPointURL).responseJSON { response in
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                success()
            }
        }
    }

}

extension LoginAppManager: RequestAdapter, RequestRetrier {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let accessToken = AccessToken.restore() else {
            log.info("No access token for request")
            return urlRequest
        }
        
        var result = urlRequest
        result.setValue("Bearer " + accessToken , forHTTPHeaderField: "Authorization")
        
        return result
    }
    
    func should(_ manager: SessionManager,
                retry request: Request,
                with error: Error,
                completion: @escaping RequestRetryCompletion)
    {
        if request.response?.statusCode == 403 {
            completion(false, 0)
        } else if request.response?.statusCode == 400 {
            completion(false, 0)
        } else {
            if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                NotificationCenter.default.post(name: .AppNotConnectedToInternet, object: error)
            }
            
            if let error = error as? URLError, error.code == URLError.networkConnectionLost, request.retryCount < 20 {
                completion(true, 3)
            } else {
                completion(false, 0)
            }
        }
    }
}
