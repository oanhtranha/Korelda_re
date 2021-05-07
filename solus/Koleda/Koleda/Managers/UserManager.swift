//
//  UserManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/11/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PromiseKit
import GoogleSignIn
import SwiftyJSON

protocol UserManager {
    func getCurrentUser(success: (() -> Void)?, failure: ((Error) -> Void)?)
    func logOut(completion: @escaping () -> Void)
    func getFriendsList(success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func inviteFriend(email: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func removeFriend(friendEmail: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func leaveFromMasterHome(success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func joinHome(name: String, email: String, password: String, homeId: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
}


class UserManagerImpl: UserManager {
    private let sessionManager: Session
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    init(sessionManager: Session) {
        self.sessionManager =  sessionManager
    }
    
    func getCurrentUser(success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("user/me"), method: .get) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure?(WSError.general)
            }
            return
        }
        
        sessionManager
            .request(request).validate().responseData { response in
                switch response.result {
                case .success(let data):
                    do {
						log.info(try JSON(data: data).description)
                        let decodedJSON = try JSONDecoder().decode(User.self, from: data)
                        UserDataManager.shared.currentUser = decodedJSON
                        UserDataManager.shared.temperatureUnit = TemperatureUnit(fromString: UserDataManager.shared.currentUser?.temperatureUnit ?? "C")
                        success?()
                    } catch {
                        log.info("Get Current User parsing error: \(error)")
                        failure?(error)
                    }
                case .failure(let error):
                    log.info("Get Current User fetch error: \(error)")
                    failure?(error)
                }
        }
    }
    func getFriendsList(success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void){
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/partners/getPartnerByList"), method: .get) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure(WSError.general)
            }
            return
        }
        
        sessionManager
            .request(request).validate().responseData { response in
                switch response.result {
                case .success(let data):
                    do {
//                        let json = try JSON(data: data)
//                        log.info(json.description)
//                        UserDataManager.shared.friendsList = json["partnerEmails"] as? [String] ?? []
                        let decodedJSON = try JSONDecoder().decode([String].self, from: data)
                        UserDataManager.shared.friendsList = decodedJSON
                        
                        success()
                    } catch {
                        log.info("Get List Friends parsing error: \(error)")
                        failure(error)
                    }
                case .failure(let error):
                    log.info("Get List Friends fetch error: \(error)")
                    failure(error)
                }
        }
    }
    
    func inviteFriend(email: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let params = ["email": email]
        let endPointURL = baseURL().appendingPathComponent("me/partners")
        guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().responseJSON { [weak self] response in
            switch response.result {
            case .success( _):
                log.info("Successfully invite friend")
                UserDataManager.shared.friendsList.append(email)
                success()
            case .failure(let error):
                log.error("Failed to invite friend - \(error)")
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
    
    func joinHome(name: String, email: String, password: String, homeId: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let timezone = TimeZone.current.identifier
        let params = ["name": name,
                      "email": email,
                      "password": password,
                      "homeId":homeId,
                      "zoneId": timezone]
        guard let request = URLRequest.postRequestWithJsonBody(url: baseURL().appendingPathComponent("auth/joinHome"), parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().responseJSON { response in
            switch response.result {
            case .success(let result):
                log.info("Successfully joining Home")
                success()
            case .failure(let error):
                log.error("Failed to joining Home - \(error)")
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
    
    func removeFriend(friendEmail: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/partners/\(friendEmail)"), method: .delete) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure(WSError.general)
            }
            return
        }
        
        sessionManager.request(request).validate().response {  [weak self] response in
            if let error = response.error {
                log.info("Removed Friend error: \(error)")
                failure(error)
            } else {
                log.info("Removed Friend successfull")
                success()
            }
        }
    }
    
    func leaveFromMasterHome(success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/partners/leave"), method: .delete) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure(WSError.general)
            }
            return
        }
        
        sessionManager.request(request).validate().response {  [weak self] response in
            if let error = response.error {
                log.info("Leave Home error: \(error)")
                failure(error)
            } else {
                log.info("Leave Home successfull")
                success()
            }
        }
    }
    
    
    private func logOutRemotely() -> Promise<Void> {
        return Promise<Void> { seal -> Void in
            let endPointURL = baseURL().appendingPathComponent("auth/logout")
            guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: [:]) else {
                seal.reject(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
                return
            }
            
            sessionManager.request(request).validate().response { response in
                if let error = response.error {
                    if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                        NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                    } else {
                        log.error("Failed performing logout")
                    }
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }
    
    func logOut(completion: @escaping () -> Void) {
        firstly {
                return cancelAllTasks()
            }.then {
                return self.logOutRemotely()
            }.always {
                UserDefaultsManager.removeUserValues()
                try? LocalAccessToken.delete()
                try? RefreshToken.delete()
                UserDataManager.shared.clearUserData()
                log.info("Logged out")
                completion()
        }
    }
    
    private func signOutGoogle() {
        do {
            try GIDSignIn.sharedInstance().signOut()
                GIDSignIn.sharedInstance().disconnect()
            
            if let url = NSURL(string:  "https://www.google.com/accounts/Logout?continue=https://appengine.google.com/_ah/logout?continue=https://google.com"){
                UIApplication.shared.open(url as URL, options: [:]) { (true) in
                }
            }
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    private func cancelAllTasks() -> Promise<Void> {
        return Promise<Void> { seal -> Void in
            sessionManager.session.getAllTasks { tasks in
                tasks.forEach { $0.cancel() }
                
                log.info("Cancelled all tasks")
                seal.fulfill(())
            }
        }
    }
    
}

