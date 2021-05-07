//
//  ManagerProvider.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Alamofire

class ManagerProvider {
    
    static let sharedInstance: ManagerProvider = {
        let geoLocationManager = GeoLocationManager()
        let loginAppManager = LoginAppManager()
        return ManagerProvider(loginAppManager: loginAppManager, geoLocationManager: geoLocationManager)
    }()
    
    
    init(loginAppManager: LoginAppManager, geoLocationManager: GeoLocationManager) {
        self.loginAppManager = loginAppManager
        self.geoLocationManager = geoLocationManager
    }
    
    
    
    // Available Managers
    
    private (set) lazy var popupWindowManager = PopupWindowManager()
    
    var signUpManager: SignUpManager {
        return SignUpManagerImpl(sessionManager: loginAppManager.sessionManager)
    }
    
    var userManager: UserManager {
        return UserManagerImpl(sessionManager: loginAppManager.sessionManager)
    }
    
	var homeManager: HomeManager {
		return HomeManagerImpl(sessionManager: loginAppManager.sessionManager)
	}
	
    var roomManager: RoomManager {
        return RoomManagerImpl(sessionManager: loginAppManager.sessionManager)
    }
    
    var shellyDeviceManager: ShellyDeviceManagerImpl {
        return ShellyDeviceManagerImpl(sessionManager: loginAppManager.sessionManager)
    }
    
    var settingManager: SettingManager {
        return SettingManagerImpl(sessionManager: loginAppManager.sessionManager)
    }
    
    var websocketManager: WebsocketManager {
        return WebsocketManager.shared
    }
    
    var schedulesManager: SchedulesManager {
        return SchedulesManagerImpl(sessionManager: loginAppManager.sessionManager)
    }
    
    let geoLocationManager: GeoLocationManager
    let loginAppManager: LoginAppManager
    
}

