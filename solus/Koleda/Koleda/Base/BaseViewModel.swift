//
//  BaseViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import Alamofire

enum ViewModelActionResult {
    case success
    case error(String)
}

enum RequestError: Error {
    case error(String)
}

class BaseViewModel: NSObject {

    override convenience init() {
        self.init()
    }
    
    init(managerProvider: ManagerProvider = .sharedInstance) {
        super.init()
    }
    
    var isOffline: Bool {
        if let isReachable = NetworkReachabilityManager()?.isReachable {
            return !isReachable
        }
        return true
    }
}

