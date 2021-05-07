//
//  DeviceManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/18/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

protocol ShellyDeviceManager {
    func getDeviceInfoOnAPMode(success: ((String) -> Void)?, failure: ((Error) -> Void)?)
    func turnOnSTAOfDeviceInfo(ssid: String, pass: String, success: (() -> Void)?, failure: ((Error) -> Void)?)
    
    func setMQTTForDevice(isSensor: Bool, deviceModel: String, ipAddress: String?, completion: @escaping (Bool) -> Void)
    func addDevice(roomId: String, sensor: Sensor?, heater: Heater?, completion: @escaping (WSError?) -> Void)
    func deleteDevice(roomId: String, deviceId: String, success: (() -> Void)?, failure: ((Error) -> Void)?)
}


class ShellyDeviceManagerImpl: ShellyDeviceManager {

    private let sessionManager: Session
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    init(sessionManager: Session) {
        self.sessionManager =  sessionManager
    }
    
    func getDeviceInfoOnAPMode(success: ((String) -> Void)?, failure: ((Error) -> Void)?) {
        AF.request("\(AppConstants.defaultShellyHostLink)/settings").responseJSON { response in
            switch response.result {
            case let .success(value):
                print(value)
                let data = JSON(value)
                let deviceModel = data["name"].stringValue
                success?(deviceModel)
            case let .failure(error):
                print(error)
                failure?(WSError.general)
            }
//            if let json = response.result.value {
//                print("JSON: \(json)") // serialized json response
//                let data = JSON(json)
//                let deviceModel = data["name"].stringValue
//                success?(deviceModel)
//            } else {
//
//            }
        }
    }

    func turnOnSTAOfDeviceInfo(ssid: String, pass: String, success: (() -> Void)?, failure: ((Error) -> Void)?) {
        let params: Parameters = ["enabled": 1,
                                  "ssid": ssid,
                                  "key": pass,
                                  "ipv4_method": "dhcp",
                                  "ip": "" ,
                                  "gw": "",
                                  "mask": "",
                                  "dns": "" ]
        guard let url = URL(string: "\(AppConstants.defaultShellyHostLink)/settings/sta" ) else {
            return
        }
        let sessionManager = Alamofire.Session.default
        sessionManager.request(url,
                               method: .post,
                               parameters: params,
                               headers: ["Content-Type": "application/x-www-form-urlencoded"])
            .validate()
            .responseJSON { [weak self] response in
                if let error = response.error {
                    failure?(WSError.general)
                } else {
//                    if let json = response.result {
//                        print("JSON: \(json)") // serialized json response
//                    }
                    success?()
                }
            }
    }
    
    func addDevice(roomId: String, sensor: Sensor?, heater: Heater?, completion: @escaping (WSError?) -> Void) {
        var name: String = ""
        var type: String = ""
        var deviceModel: String = ""
        var ipAddressDevice: String?
        if let device = sensor {
            name = device.name
            deviceModel = device.deviceModel
            ipAddressDevice = device.ipAddress
            type = "SENSOR"
        } else if let device = heater {
            name = device.name
            deviceModel = device.deviceModel
            ipAddressDevice = device.ipAddress
            type = "HEATER"
        }
        let params = ["deviceModel": deviceModel,
                      "name": name,
                      "type": type]
        let endPointURL = self.baseURL().appendingPathComponent("me/rooms/\(roomId)/device")
        guard let request = URLRequest.requestWithJsonBody(url: endPointURL, method: .put, parameters: params) else {
            log.error("Failed to send request, please try again later")
            completion(WSError.general)
            return
        }
        
        self.sessionManager.request(request).validate().response { response in
            if let error = response.error {
                log.info("Failed to add Shelly Device - \(type)")
                let error = WSError.error(from: response.data, defaultError: WSError.general)
                completion(error)
            } else {
                log.info("Successfully add Shelly Device - \(type)")
                completion(nil)
            }
        }
    }
    
    func setMQTTForDevice(isSensor: Bool, deviceModel: String, ipAddress: String?, completion: @escaping (Bool) -> Void) {
        var params: [String : Any] = ["mqtt_enable": 1,
                      "mqtt_server": UrlConfigurator.mqttUrlString(), 
                      "mqtt_user": "mqtt",
                      "mqtt_reconnect_timeout_max": 60,
                      "mqtt_reconnect_timeout_min": 2,
                      "mqtt_clean_session": true,
                      "mqtt_keep_alive": 60,
                      "mqtt_will_topic": "shellies/\(deviceModel)/online",
                      "mqtt_will_message": true,
                      "mqtt_max_qos": 0,
                      "mqtt_pass": "mqtt",
                      "external_power": 0]
        if isSensor {
            params["mqtt_update_period"] = 5
            params["mqtt_retain"] = true
            params["temperature_threshold"] = 0.5
        } else {
            params["mqtt_retain"] = false
        }
        
        guard let ipAddress = ipAddress else {
            completion(false)
            return
        }
//        let originalIPAddress = ipAddress.app_removePortInUrl()
        guard let endPointURL = URL(string: "http://\(ipAddress)/settings" ) else {
            completion(false)
            return
        }
        
        let sessionManager = Alamofire.Session.default
        sessionManager.request(endPointURL,
                               method: .post,
                               parameters: params,
                               headers: ["Content-Type": "application/x-www-form-urlencoded"])
            .validate()
            .responseJSON { [weak self] response in
                if let error = response.error {
                    log.info("Failed to set MQTT Shelly Device - \(deviceModel)")
                    completion(false)
                } else {
                    log.info("Successfull to set MQTT Shelly Device - \(deviceModel)")
                    if isSensor {
                        completion(true)
                    } else {
                        self?.ignoreManualPressingOnHeater(ipAddress: ipAddress, completion: { success in
                            completion(success)
                        })
                    }
           }
        }
    }
    
    private func ignoreManualPressingOnHeater(ipAddress: String, completion: @escaping (Bool) -> Void) {
        setupButtonType(ipAddress: ipAddress) { [weak self] isSuccess in
            if isSuccess {
                self?.setupButtonReverse(ipAddress: ipAddress, completion: { success in
                    completion(success)
                })
            } else {
                completion(isSuccess)
            }
        }
    }
    
    private func setupButtonType(ipAddress: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://\(ipAddress)/settings/relay/0?btn_type=toggle" ) else {
            return
        }
        let sessionManager = Alamofire.Session.default
        sessionManager.request(url,
                               method: .get,
                               headers: ["Content-Type": "application/x-www-form-urlencoded"])
            .validate()
            .responseJSON { [weak self] response in
                if let error = response.error {
                    log.info("Failed to ignoreManualPressingOnHeaterBySetButtonType")
                    completion(false)
                } else {
                    log.info("Successfull to ignoreManualPressingOnHeaterBySetButtonType")
                    completion(true)
                }
        }
    }
    
    private func setupButtonReverse(ipAddress: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://\(ipAddress)/settings/relay/0?btn_reverse=1" ) else {
            return
        }
        let sessionManager = Alamofire.Session.default
        sessionManager.request(url,
                               method: .get,
                               headers: ["Content-Type": "application/x-www-form-urlencoded"])
            .validate()
            .responseJSON { [weak self] response in
                if let error = response.error {
                    log.info("Failed to ignoreManualPressingOnHeaterBySetButtonReverse")
                    completion(false)
                } else {
                    log.info("Successfull to ignoreManualPressingOnHeaterBySetButtonReverse")
                    completion(true)
                }
        }
    }
    
    
    func deleteDevice(roomId: String, deviceId: String, success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/rooms/\(roomId)/device/\(deviceId)"), method: .delete) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure?(WSError.general)
            }
            return
        }
        
        sessionManager.request(request).validate().response {  [weak self] response in
            if let error = response.error {
                log.info("Delete Shelly Device error: \(error)")
                failure?(error)
            } else {
                log.info("Delete Shelly Device successfull")
                success?()
            }
        }
    }
}
