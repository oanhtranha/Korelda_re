//
//  SettingManager.swift
//  Koleda
//
//  Created by Oanh tran on 8/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Sync

protocol SettingManager {
    func updateTariff(tariff: Tariff, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func getTariff(success: (() -> Void)?, failure: ((Error) -> Void)?)
    func updateSettingMode(mode: String, roomId: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func getEnergyConsumed(success: (() -> Void)?, failure: ((Error) -> Void)?)
    func resetManualBoost(roomId: String, success: (() -> Void)?, failure: ((Error) -> Void)?)
    func loadSettingModes(success: (() -> Void)?, failure: ((Error) -> Void)?)
    func updateTemperatureUnit(temperatureUnit: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func updateTempMode(modeName: String, temp: Double, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
}


class SettingManagerImpl: SettingManager {
    
    private let sessionManager: Session
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    init(sessionManager: Session) {
        self.sessionManager =  sessionManager
    }
    
    func updateTariff(tariff: Tariff, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let params: [String : Any] = ["dayTimeStart" : tariff.dayTimeStart.removingOccurances([" "]),
                                      "dayTimeEnd" : tariff.dayTimeEnd.removingOccurances([" "]),
                                      "dayTariff" : tariff.dayTariff,
                                      "nightTimeStart" : tariff.nightTimeStart.removingOccurances([" "]),
                                      "nightTimeEnd" : tariff.nightTimeEnd.removingOccurances([" "]),
                                      "nightTariff" : tariff.nightTariff,
                                      "currency" : tariff.currency]
        let endPointURL = baseURL().appendingPathComponent("me/tariff")
        guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().response { response in
            if let error = response.error {
                if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                    NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                } else {
                    log.error("Failed to update Tariff")
                }
                failure(error)
            } else {
                log.info("Successfully update Tariff")
                success()
            }
        }
    }
    
    func getTariff(success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        log.info("getTariff")
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/tariff"), method: .get) else {
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
                        let decodedJSON = try JSONDecoder().decode(Tariff.self, from: data)
                        UserDataManager.shared.tariff = decodedJSON
                        success?()
                    } catch {
                        log.info("Get Tariff parsing error: \(error)")
                        failure?(error)
                    }
                case .failure(let error):
                    log.info("Get Tariff fetch error: \(error)")
                    failure?(error)
                }
        }
    }
    
    func updateSettingMode(mode: String, roomId: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        let params: [String : Any] = ["mode" : mode]
        let endPointURL = baseURL().appendingPathComponent("setting/rooms/\(roomId)/mode")
        guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().response { response in
            if let error = response.error {
                if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                    NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                } else {
                    log.error("Failed to update Setting Mode")
                }
                failure(error)
            } else {
                log.info("Successfully update Setting Mode")
                success()
            }
        }
    }
    
    func getEnergyConsumed(success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/tariff/energy"), method: .get) else {
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
                        let json = try JSON(data: data)
                        UserDataManager.shared.energyConsumed = ConsumeEneryTariff(energyConsumedMonth: json["energyConsumedMonth"].doubleValue, energyConsumedWeek: json["energyConsumedWeek"].doubleValue, energyConsumedDay: json["energyConsumedDay"].doubleValue)
                        success?()
                    } catch {
                        log.info("Get Tariff parsing error: \(error)")
                        failure?(error)
                    }
                case .failure(let error):
                    log.info("Get Tariff fetch error: \(error)")
                    failure?(error)
                }
        }
    }
    
    func resetManualBoost(roomId: String, success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("setting/rooms/\(roomId)/temperature"), method: .delete) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure?(WSError.general)
            }
            return
        }
        
		sessionManager.request(request).validate().response { [weak self] response in
			if let error = response.error {
				log.error("Failed to manual boost update - \(error)")
				failure?(error)
			} else {
				log.info("reset Manual Boost Successfully")
				success?()
			}
		}
    }
    
    func loadSettingModes(success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("modes"), method: .get) else {
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
                        let json = try JSON(data: data)
                        guard let jsonArray = json.arrayObject as? [[String: Any]] else {
                            return
                        }
                        print(jsonArray)
                        self.loadSettingModes(modesDic: jsonArray)
                        success?()
                    } catch {
                        log.info("Get modes parsing error: \(error)")
                        self.loadDefaultSettingModes()
                        failure?(error)
                    }
                case .failure(let error):
                    log.info("Get modes fetch error: \(error)")
                    self.loadDefaultSettingModes()
                    failure?(error)
                }
        }
    }
    
    func updateTempMode(modeName: String, temp: Double, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let params: [String : Any] = ["temp" : temp]
        let endPointURL = baseURL().appendingPathComponent("modes/\(modeName)")
        
        sessionManager.request(endPointURL,
                               method: .put,
                               parameters: params,
                               encoding: JSONEncoding.default)
            .validate()
            .response { response in
                if let error = response.error {
                    if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                        NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                    } else {
                        log.error("Failed to update Temperature Mode")
                    }
                    failure(error)
                } else {
                    log.info("Successfully update Temperature Mode")
                    success()
                }
        }
    }
    
    func updateTemperatureUnit(temperatureUnit: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        let params: [String : Any] = ["temperatureUnit" : temperatureUnit,
                                      "name" : "",
                                      "zoneId" : ""]
        let endPointURL = baseURL().appendingPathComponent("user/me")
        
        sessionManager.request(endPointURL,
                               method: .patch,
                               parameters: params,
                               encoding: JSONEncoding.default)
            .validate()
            .response { response in
            if let error = response.error {
                if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
                    NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
                } else {
                    log.error("Failed to update Temperature Unit")
                }
                failure(error)
            } else {
                log.info("Successfully update Temperature Unit")
                success()
            }
        }
    }
    
   
    
    private func loadSettingModes(modesDic: [[String: Any]]) {
        var settingModes: [ModeItem] = []
        for dic in modesDic {
            let mode = dic["mode"] as? String ?? ""
            let temp = dic["temperature"] as? Double ?? 0
            let smartMode = SmartMode.init(fromString: mode)
            if smartMode != .unknow {
                settingModes.append(ModeItem(mode: smartMode, title: ModeItem.titleOf(smartMode: smartMode), icon: ModeItem.imageOf(smartMode: smartMode), temp: temp))
            }
           
        }
        UserDataManager.shared.settingModes = settingModes
    }
        
    private func loadDefaultSettingModes() {
        var settingModes: [ModeItem] = []
        settingModes.append(ModeItem(mode: .ECO, title: ModeItem.titleOf(smartMode: .ECO), icon: ModeItem.imageOf(smartMode: .ECO), temp: 19.0))
        settingModes.append(ModeItem(mode: .NIGHT, title: ModeItem.titleOf(smartMode: .NIGHT), icon: ModeItem.imageOf(smartMode: .NIGHT), temp: 17.0))
        settingModes.append(ModeItem(mode: .COMFORT, title: ModeItem.titleOf(smartMode: .COMFORT), icon: ModeItem.imageOf(smartMode: .COMFORT), temp: 21.0))
        settingModes.append(ModeItem(mode: .DEFAULT, title: ModeItem.titleOf(smartMode: .DEFAULT), icon: ModeItem.imageOf(smartMode: .DEFAULT), temp: 20.5))
        UserDataManager.shared.settingModes = settingModes
    }
}

