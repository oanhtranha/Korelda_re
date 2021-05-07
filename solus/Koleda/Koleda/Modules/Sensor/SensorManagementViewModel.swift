//
//  SensorManagementViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 7/17/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import SwiftRichString
import CopilotAPIAccess

enum AddDeviceStatus {
    case search
    case noDevice
    case oneDevice
    case moreThanOneDevice
    case addDevice
    case addDeviceSuccess
    case joinDeviceHotSpot
}



protocol SensorManagementViewModelProtocol: BaseViewModelProtocol {
    
    var addedSuccessfullyViewHidden: PublishSubject<Bool> { get }
    var statusViewHidden: PublishSubject<Bool> { get }
    var tryAgainButtonHidden: PublishSubject<Bool> { get }
    var connectToDeviceHotspotButtonHidden: PublishSubject<Bool> { get }
    var cancelButtonHidden: PublishSubject<Bool> { get }
    var sensorViewHidden: PublishSubject<Bool> { get }
    var changeWifiForShellyDevice: PublishSubject<Void> { get }
    
    var updatedStatus: PublishSubject<AddDeviceStatus> { get }
    var detectedSensors: [Sensor] { get }
    
    var statusImage: PublishSubject<UIImage?> { get }
    var statusTitle: PublishSubject<String> { get }
    var statusSubTitle: PublishSubject<String> { get }
    var titleAttributed: NSAttributedString { get }
    var sensorModel: Variable<String> { get }
    var roomName: String { get }
    var sensorName: String { get }
    var roomNameWithUserName: String { get }
    
    
    func updateUI(with status: AddDeviceStatus)
    func updateStatusAfterSeaching()
    func getCurrentWiFiName() -> String
    func fetchInfoOfSensorAPMode(completion: @escaping (Bool) -> Void)
    func findSensorsOnLocalNetwork(completion: @escaping () -> Void)
    func waitingSensorsJoinNetwork(completion: @escaping () -> Void)
    func connectSensorLocalWifi(ssid: String, pass: String, completion: @escaping (Bool) -> Void)
    func addASensorToARoom(completion: @escaping (WSError?) -> Void)
    func goAddHeaterFlow()
    func showWifiDetail()
}

class SensorManagementViewModel: BaseViewModel, SensorManagementViewModelProtocol  {
  
    
    let router: BaseRouterProtocol
    
    var addedSuccessfullyViewHidden = PublishSubject<Bool>()
    var statusViewHidden = PublishSubject<Bool>()
    var tryAgainButtonHidden = PublishSubject<Bool>()
    var connectToDeviceHotspotButtonHidden = PublishSubject<Bool>()
    var cancelButtonHidden = PublishSubject<Bool>()
    var sensorViewHidden = PublishSubject<Bool>()
    var changeWifiForShellyDevice = PublishSubject<Void>()
    

    let updatedStatus = PublishSubject<AddDeviceStatus>()
    var detectedSensors: [Sensor] = []
    
    let statusImage = PublishSubject<UIImage?>()
    let statusTitle = PublishSubject<String>()
    let statusSubTitle = PublishSubject<String>()
    var titleAttributed: NSAttributedString
    let sensorModel = Variable<String>("")
    var roomName: String
    var roomNameWithUserName: String
    private let shellyDeviceManager: ShellyDeviceManager
    private let roomId: String
    var sensorName: String = ""
   
    private let netServiceClient = NetServiceClient()
    
    private var timer:Timer?
    private var timeLeft = 3
    private var waiting = true
    
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance, roomId: String, roomName: String) {
        self.router = router
        self.shellyDeviceManager = managerProvider.shellyDeviceManager
        self.roomId = roomId
        self.roomName = roomName
        let normal = SwiftRichString.Style{
            $0.font = UIFont.app_FuturaPTLight(ofSize: 30)
            $0.color = UIColor.hex1F1B15
        }
        
        let bold = SwiftRichString.Style {
            $0.font = UIFont.app_FuturaPTDemi(ofSize: 30)
            $0.color = UIColor.hex1F1B15
        }
        if let userName = UserDataManager.shared.currentUser?.name {
            roomNameWithUserName = "\(userName)’s \(roomName)"
        } else {
            roomNameWithUserName = "\(roomName)"
        }
        let group = StyleGroup(base: normal, ["h1": bold])
        let string = String(format: "ADD_A_SENSOR_TO_ROOM_TEXT".app_localized, roomNameWithUserName)
        self.titleAttributed =  string.set(style: group)
        super.init(managerProvider: managerProvider)
    }
    
    
    func updateUI(with status: AddDeviceStatus) {
        switch status {
        case .search:
            statusImage.onNext(nil)
            statusTitle.onNext("")
            statusSubTitle.onNext("SEARCHING_FOR_SENSOR_TEXT".app_localized)
            cancelButtonHidden.onNext(false)
        case .noDevice:
            statusImage.onNext(nil)
            statusTitle.onNext("NO_SENSOR_IN_THIS_ROOM".app_localized)
            statusSubTitle.onNext("INSTRUCTION_FOR_SET_UP_SENSOR_MESS".app_localized)
            cancelButtonHidden.onNext(true)
        case .oneDevice:
            statusImage.onNext(nil)
            statusTitle.onNext("DETECT_ONE_SENSOR_MESS".app_localized)
            statusSubTitle.onNext("TAP_TO_CONNECT".app_localized)
            sensorModel.value = self.detectedSensors[0].deviceModel
            cancelButtonHidden.onNext(true)
        case .moreThanOneDevice:
            statusImage.onNext(nil)
            statusTitle.onNext("THERE_IS_MORE_THAN_ONE_SENSOR_MESS".app_localized)
            statusSubTitle.onNext("FOLLOW_THE_INSTRUCTION_TO_CONNECT".app_localized)
            cancelButtonHidden.onNext(true)
        case .addDevice:
            statusImage.onNext(UIImage(named: "ic-adding-sensor"))
            statusTitle.onNext("ADDING_SENSOR_TEXT".app_localized)
            statusSubTitle.onNext("PLEASE_WAIT_TEXT".app_localized)
            cancelButtonHidden.onNext(false)
        case .addDeviceSuccess:
            statusImage.onNext(UIImage(named: "ic-addedSuccessfully"))
            statusTitle.onNext("SENSOR_ADDED_SUCCES_MESS".app_localized)
            statusSubTitle.onNext("")
            cancelButtonHidden.onNext(true)
        case .joinDeviceHotSpot:
            statusImage.onNext(nil)
            statusTitle.onNext("NO_SENSOR_IN_THIS_ROOM".app_localized)
            statusSubTitle.onNext("INSTRUCTION_FOR_SET_UP_SENSOR_MESS".app_localized)
            cancelButtonHidden.onNext(true)
            changeWifiForShellyDevice.onNext(())
        }
        
        statusViewHidden.onNext(status == .joinDeviceHotSpot)
        tryAgainButtonHidden.onNext(![.noDevice, .moreThanOneDevice].contains(status))
        connectToDeviceHotspotButtonHidden.onNext(![.noDevice].contains(status))
        sensorViewHidden.onNext(![.oneDevice, .addDevice].contains(status))
        addedSuccessfullyViewHidden.onNext(status != .addDeviceSuccess)
        
    }
    
    func waitingSensorsJoinNetwork(completion: @escaping () -> Void) {
        waiting = true
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: waiting)
        completion()
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
    
    func addASensorToARoom(completion: @escaping (WSError?) -> Void) {
        guard detectedSensors.count > 0 else {
            completion(WSError.general)
            return
        }
        let sensor = detectedSensors[0]
        shellyDeviceManager.addDevice(roomId: roomId, sensor: sensor, heater: nil) { [weak self] error in
            guard let `self` = self else {
                return
            }
            self.sensorName = self.detectedSensors[0].deviceModel
            Copilot.instance.report.log(event: AddSensorAnalyticsEvent(sensorModel: sensor.deviceModel, roomId: self.roomId, homeId: UserDataManager.shared.currentUser?.homes[0].id ?? "", screenName: self.screenName))
            completion(error)
        }
    }
    
    func goAddHeaterFlow() {
        router.enqueueRoute(with: SensorManagementRouter.RouteType.addHeaterFlow(self.roomId, self.roomName))
    }
    
    private func setMQTTServerForSensor(sensor: Sensor, completion: @escaping (Bool) -> Void) {
        shellyDeviceManager.setMQTTForDevice(isSensor: true, deviceModel: sensor.deviceModel, ipAddress: sensor.ipAddress) { isSuccess in
            completion(isSuccess)
        }
    }
    
    private func changeWifiForDevice(ssid: String, pass: String){
        if TARGET_IPHONE_SIMULATOR == 0 {
            
            if #available(iOS 11.0, *) {
                let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: pass, isWEP: false)
                configuration.joinOnce = false
                NEHotspotConfigurationManager.shared.apply(configuration, completionHandler: { (err: Error?) in
                    print(err)
                })
            } else {
                // Fallback on earlier versions
            }
        }// if TARGET_IPHONE_SIMULATOR == 0
    }
    
}

extension SensorManagementViewModel {
    
    func updateStatusAfterSeaching() {
        let detectedSensorsNumber = detectedSensors.count
        let status: AddDeviceStatus = detectedSensorsNumber == 0 ? .noDevice : (detectedSensorsNumber == 1 ? .oneDevice : .moreThanOneDevice)
        updateUI(with: status)
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
    
    
    func fetchInfoOfSensorAPMode(completion: @escaping (Bool) -> Void) {
        shellyDeviceManager.getDeviceInfoOnAPMode(success: { deviceModel in
            completion(true)
            },
        failure: { error in
            completion(false)
        })
    }
    
    func findSensorsOnLocalNetwork(completion: @escaping () -> Void) {
        do {
            netServiceClient.log = { print("NetService:", $0) }
            
            var services = Set<Service>()
            let end = Date() + 7.0
            try netServiceClient.discoverServices(of: .http,
                                                  in: .local,
                                                  shouldContinue: { Date() < end },
                                                  foundService: { services.insert($0) })
            var sensors: [Sensor] = []
            guard services.count > 0 else {
                completion()
                return
            }
            for service in services {
                let hostName = service.name
                log.info(hostName)
                if DataValidator.isShellyDevice(hostName: hostName) && !UserDataManager.shared.deviceModelList.contains(hostName) {
//                    let addresses = try netServiceClient.resolve(service, timeout: 1.0)
//                    let ipAddress = addresses.description
                    let ipAddress = String(format: "%@.local",hostName)
                    log.info(ipAddress)
                    let sensor: Sensor = Sensor(deviceModel: hostName, name: hostName, ipAddress: ipAddress)
                    sensors.append(sensor)
                }
            }
            if sensors.count == 1 {
                setMQTTServerForSensor(sensor: sensors[0]) { isSuccess in
                    self.detectedSensors = isSuccess ? sensors : []
                    completion()
                }
            } else {
                detectedSensors = sensors
                completion()
            }
        }
        catch {
            log.error("\(error)")
            detectedSensors = []
//            let sensor: Sensor = Sensor(deviceModel: "Shellyht-DEEDD3", name: "Shellyht-DEEDD3", ipAddress: "Shellyht-DEEDD3")
//            let sensor1: Sensor = Sensor(deviceModel: "Shellyht-DEE3FG", name: "Shellyht-DEE3FG", ipAddress: "Shellyht-DEE3FG")
//            detectedSensors = [sensor]
            completion()
        }
    }
    
    func connectSensorLocalWifi(ssid: String, pass: String, completion: @escaping (Bool) -> Void) {
        self.shellyDeviceManager.turnOnSTAOfDeviceInfo(ssid: ssid, pass: pass, success: { [weak self] in
            self?.changeWifiForDevice(ssid: ssid, pass: pass)
            completion(true)
            }, failure: { error in
            completion(false)
        })
    }
    
    func showWifiDetail() {
        router.enqueueRoute(with: SensorManagementRouter.RouteType.wifiDetail)
    }
}
