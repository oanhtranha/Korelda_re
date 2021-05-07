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
    
    var sessionManager: Session
    var isLoggedIn: Bool {
        return UserDefaultsManager.loggedIn.enabled
    }
    
    init() {
        let adapter = MyRequestAdapter()
        sessionManager = Session(configuration: .default, interceptor: adapter)
    }
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    func login(email: String, password: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        let timezone = TimeZone.current.identifier
        let params = ["email": email,
                      "password": password,
                      "zoneId": timezone]
        let endPointURL = baseURL().appendingPathComponent("auth/login")
        log.info(endPointURL.description)
        guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        AF.request(request).validate().responseJSON { response in
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
                    NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                    failure(error)
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
    
    func loginWithSocial(type: SocialType, accessToken: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
    
        let timezone = TimeZone.current.identifier
        let endPointURL = baseURL().appendingPathComponent("auth/login-social")
        log.info(accessToken)
		let params = ["provider": type.rawValue,
                      "token": accessToken,
                      "zoneId" : timezone]
        guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        AF.request(request).validate().responseJSON { response in
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
                    NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                    failure(error)
                } else {
                    let error = WSError.error(from: response.data, defaultError: WSError.general)
                    failure(error)
                }
            }
        }
    }
}

class MyRequestAdapter: Alamofire.RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let accessToken = LocalAccessToken.restore() else {
            log.info("No access token for request")
            return completion(.success(urlRequest))
        }
        
        var result = urlRequest
        result.setValue("Bearer " + accessToken , forHTTPHeaderField: "Authorization")
        
        return completion(.success(result))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            /// The request did not fail due to a 401 Unauthorized response.
            /// Return the original error and don't retry the request.
            return completion(.doNotRetryWithError(error))
        }
        if request.response?.statusCode == 403 {
            completion(.doNotRetryWithError(error))
        } else if request.response?.statusCode == 400 {
            completion(.doNotRetryWithError(error))
        } else {
            if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
            }
            
            if let error = error as? URLError, error.code == URLError.networkConnectionLost, request.retryCount < 20 {
                completion(.retry)
            } else {
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
