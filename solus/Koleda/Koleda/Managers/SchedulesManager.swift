//
//  SchedulesManager.swift
//  Koleda
//
//  Created by Oanh Tran on 2/28/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Sync

protocol SchedulesManager {
    func getSmartSchedule(dayString: String, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void))
    func checkExistingSmartSchedules(roomId: String, completion: @escaping ((Bool) -> Void))
    func updateSmartSchedule(schedules: ScheduleOfDay, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func turnOnOrOffSmartSchedule(roomId: String, turnOn: Bool, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
}

class SchedulesManagerImpl: SchedulesManager {
    
    private let sessionManager: Session
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    init(sessionManager: Session) {
        self.sessionManager = sessionManager
    }
    
    func getSmartSchedule(dayString: String, success: @escaping (() -> Void), failure: @escaping ((Error) -> Void)) {
        
        let endpoint = "schedulers?dayOfWeek=\(dayString)"
        guard let url = URL(string: baseURL().absoluteString + endpoint) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        guard let request = try? URLRequest(url: url, method: .get) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure(WSError.general)
            }
            return
        }
        
        sessionManager.request(request).validate().responseData { response in
            switch response.result {
			case .success(let data):
                do {
                    log.info(try JSON(data: data).description)
                    let decodedJSON = try JSONDecoder().decode(ScheduleOfDay.self, from: data)
                    UserDataManager.shared.smartScheduleData[dayString] = decodedJSON
                    success()
                } catch {
                    log.info("Get Schedule parsing error: \(error)")
                    failure(error)
                }
            case .failure(let error):
                log.info("Get Schedule fetch error: \(error)")
                if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                    NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                    failure(error)
                } else if let error = error as? AFError, error.responseCode == 400 {
                    failure(error)
                } else if let error = error as? AFError, error.responseCode == 401 || error.responseCode == 403 {
                    failure(WSError.loginSessionExpired)
                } else {
                    failure(error)
                }
            }
        }
    }
    
    func updateSmartSchedule(schedules: ScheduleOfDay, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        let params = schedules.convertToDictionary()
        print(JSON(params))
        guard let request = URLRequest.postRequestWithJsonBody(url: baseURL().appendingPathComponent("schedulers"), parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().response { response in
            if let error = response.error {
                if let error = error as? AFError, error.responseCode == 400 {
                    failure(WSError.empty)
                } else {
                    failure(WSError.general)
                }
            } else {
                NotificationCenter.default.post(name: .KLDNeedToUpdateSchedules, object: nil)
                success()
            }
        }
    }
    
    func checkExistingSmartSchedules(roomId: String, completion: @escaping ((Bool) -> Void)) {
        let endpoint = "schedulers/rooms/\(roomId)"
        guard let url = URL(string: baseURL().absoluteString + endpoint) else {
            completion(false)
            return
        }
        
        guard let request = try? URLRequest(url: url, method: .get) else {
            assertionFailure()
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        sessionManager.request(request).validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSON(data: data)
                    let scheduleStatus = json["scheduleStatus"].boolValue
                    completion(scheduleStatus)
                } catch {
                    log.info("Get Schedules of room \(error)")
                    completion(false)
                }
            case .failure(let error):
                log.info("Get Schedules of room error: \(error)")
                completion(false)
            }
        }
    }
    
    func turnOnOrOffSmartSchedule(roomId: String, turnOn: Bool, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let params: [String : Any] = ["scheduleAction" : turnOn]
        guard let request = URLRequest.postRequestWithJsonBody(url: baseURL().appendingPathComponent("setting/rooms/\(roomId)/schedules"), parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().response { response in
            if let error = response.error {
                if let error = error as? AFError, error.responseCode == 400 {
                    failure(WSError.empty)
                } else {
                    failure(WSError.general)
                }
            } else {
                success()
            }
        }
    }
}
