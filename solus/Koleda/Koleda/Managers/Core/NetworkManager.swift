//
//  NetWorkManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/8/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Reachability
import SystemConfiguration.CaptiveNetwork

struct WifiInfo {
    let ssid: String
    let ipAddress: String
    let subNetMask: String
    let gateWay: String
    let dns: String
    
    init(ssid: String, ipAddress: String, subNetMask: String, gateWay: String, dns: String) {
        self.ssid = ssid
        self.ipAddress = ipAddress
        self.subNetMask = subNetMask
        self.gateWay = gateWay
        self.dns = dns
    }
    
    static func getWifiInfo() -> WifiInfo? {
        guard let ssid = FGRoute.getSSID(), let ip = FGRoute.getIPAddress(), let subNet = FGRoute.getSubnetMask(), let gate = FGRoute.getGatewayIP() else {
            return nil
        }
        return WifiInfo(ssid: ssid, ipAddress: ip, subNetMask: subNet, gateWay: gate, dns: "")
    }
}

class NetworkManager: ReachabilityObserverDelegate {
    
    func Connection() -> Bool{
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    func isWifi() -> Bool {
        return reachability?.connection == .wifi
    }
    
    required init() {
        addReachabilityObserver()
    }
    
    deinit {
        removeReachabilityObserver()
    }
    
    //MARK: Reachability
    
    func reachabilityChanged(_ isReachable: Bool) {
       
    }
}


//Reachability
//declare this property where it won't go out of scope relative to your listener
fileprivate var reachability: Reachability!

protocol ReachabilityActionDelegate {
    func reachabilityChanged(_ isReachable: Bool)
}

protocol ReachabilityObserverDelegate: class, ReachabilityActionDelegate {
    func addReachabilityObserver()
    func removeReachabilityObserver()
}

// Declaring default implementation of adding/removing observer
extension ReachabilityObserverDelegate {
    
    /** Subscribe on reachability changing */
    func addReachabilityObserver() {
        
        do {
          try reachability = Reachability()
        } catch {
          print("could not start reachability notifier")
        }
        reachability.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(true)
        }
        
        reachability.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(false)
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /** Unsubscribe */
    func removeReachabilityObserver() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: Notification.Name.reachabilityChanged, object: reachability)
        reachability = nil
    }
}
