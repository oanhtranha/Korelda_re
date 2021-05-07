//
//  AddHeaterViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 9/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import CopilotAPIAccess

protocol AddHeaterViewModelProtocol: BaseViewModelProtocol {
    var reSearchingHeater: PublishSubject<Bool> { get }
    var stepAddHeaters: PublishSubject<AddDeviceStatus> { get }
    var detectedHeaters: [Heater] {set get }
    var cancelButtonHidden: PublishSubject<Bool> { get }
    
    func getCurrentWiFiName() -> String
    var roomName: String { get }
    func fetchInfoOfHeaderAPMode(completion: @escaping (Bool) -> Void)
    func findHeatersOnLocalNetwork(completion: @escaping () -> Void)
    func waitingHeatersJoinNetwork(completion: @escaping () -> Void)
    
    func connectHeaterLocalWifi(ssid: String, pass: String, completion: @escaping (Bool) -> Void)
    func addAHeaterToARoom(completion: @escaping (WSError?, String, String) -> Void)
    func backToHome()
    func showWifiDetail()
    
}

class AddHeaterViewModel: BaseViewModel, AddHeaterViewModelProtocol  {
    
    let router: BaseRouterProtocol
    let reSearchingHeater = PublishSubject<Bool>()
    var cancelButtonHidden = PublishSubject<Bool>()
    var stepAddHeaters = PublishSubject<AddDeviceStatus>()
    var detectedHeaters: [Heater] = []
    
    private let shellyDeviceManager: ShellyDeviceManager
    private let roomId: String
    var roomName: String
    private let netServiceClient = NetServiceClient()
    
    private var timer:Timer?
    private var timeLeft = 3
    private var waiting = true
    
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, roomId: String, roomName: String) {
        self.router = router
        self.shellyDeviceManager = managerProvider.shellyDeviceManager
        self.roomId = roomId
        self.roomName = roomName
        super.init(managerProvider: managerProvider)
    }
    
    
    func getCurrentWiFiName() -> String {
        var ssid: String = ""
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String ?? ""
                    break
                }
            }
        }
        return ssid
    }
    
    func fetchInfoOfHeaderAPMode(completion: @escaping (Bool) -> Void) {
        shellyDeviceManager.getDeviceInfoOnAPMode(success: { [weak self] deviceModel in
            completion(true)
        },
        failure: { error in
            completion(false)
        })
    }
    
    func findHeatersOnLocalNetwork(completion: @escaping () -> Void) {
        do {
            netServiceClient.log = { print("NetService:", $0) }
            
            var services = Set<Service>()
            let end = Date() + 7.0
            try netServiceClient.discoverServices(of: .http,
                                                  in: .local,
                                                  shouldContinue: { Date() < end },
                                                  foundService: { services.insert($0) })
            var heaters: [Heater] = []
            guard services.count > 0 else {
                completion()
                return
            }
            for service in services {
                let hostName = service.name
                log.info(hostName)
                if DataValidator.isShellyHeaterDevice(hostName: hostName) && !UserDataManager.shared.deviceModelList.contains(hostName) {
//                    let addresses = try netServiceClient.resolve(service, timeout: 2.0)
//                    let ipAddress = addresses.description
                    let ipAddress = String(format: "%@.local",hostName)
                    log.info(ipAddress)
                    let heater: Heater = Heater(deviceModel: hostName, name: hostName, ipAddress: ipAddress)
                    heaters.append(heater)
                }
            }
            if heaters.count == 1 {
                setMQTTServerForHeater(heater: heaters[0]) { isSuccess in
                    self.detectedHeaters = isSuccess ? heaters : []
                    completion()
                }
            } else {
                detectedHeaters = heaters
                completion()
            }

        }
        catch {
            log.error("\(error)")
//            let heater: Heater = Heater(deviceModel: "Shelly1PM-DEE3EE", name: "Shelly1PM-DEE3EE", ipAddress: "Shelly1PM-DEE3EE")
//            let heater1: Heater = Heater(deviceModel: "Shelly1PM-DEE3FG", name: "Shelly1PM-DEE3FG", ipAddress: "Shelly1PM-DEE3FG")
//            detectedHeaters = [heater]
//            detectedHeaters = []
            completion()
        }
    }
    
    func connectHeaterLocalWifi(ssid: String, pass: String, completion: @escaping (Bool) -> Void) {
        self.shellyDeviceManager.turnOnSTAOfDeviceInfo(ssid: ssid, pass: pass, success: { 
            completion(true)
        }, failure: { error in
            completion(false)
        })
    }
    
    func waitingHeatersJoinNetwork(completion: @escaping () -> Void) {
        waiting = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: waiting)
        completion()
    }
    
    func showWifiDetail() {
        router.enqueueRoute(with: AddHeaterRouter.RouteType.wifiDetail)
    }
    
    private func setMQTTServerForHeater(heater: Heater, completion: @escaping (Bool) -> Void) {
        shellyDeviceManager.setMQTTForDevice(isSensor: false, deviceModel: heater.deviceModel, ipAddress: heater.ipAddress) { isSuccess in
            completion(isSuccess)
        }
    }

    @objc private func onTimerFires()
    {
        timeLeft -= 1
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            waiting = ((FGRoute.getSSID()?.contains("shelly") ?? false) && FGRoute.getGatewayIP() == nil)
        }
    }
    
    
    func addAHeaterToARoom(completion: @escaping (WSError?, String, String) -> Void) {
        guard detectedHeaters.count > 0 else {
            completion(WSError.general, "", "")
            return
        }
        let heater = detectedHeaters[0]
        shellyDeviceManager.addDevice(roomId: roomId, sensor: nil, heater: heater) { [weak self] error in
            guard let `self` = self else {
                return
            }
            let room = UserDataManager.shared.roomWith(roomId: self.roomId)
            guard let roomName = room?.name  else {
                completion(error, heater.deviceModel, "")
                return
            }
            Copilot.instance.report.log(event: AddHeaterAnalyticsEvent(heaterModel: heater.deviceModel, roomId: self.roomId, homeId: UserDataManager.shared.currentUser?.homes[0].id ?? "", screenName: self.screenName))
            completion(error,heater.deviceModel, roomName)
        }
    }
    
    func backToHome() {
        router.enqueueRoute(with: AddHeaterRouter.RouteType.backHome)
    }
}
