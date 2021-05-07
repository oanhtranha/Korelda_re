//
//  HomeManager.swift
//  Koleda
//
//  Created by Oanh Tran on 6/19/20.
//  Copyright © 2020 koleda. All rights reserved.
//

import Foundation
import Alamofire
import Sync
import SwiftyJSON

protocol HomeManager {
	func createHome(name: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
}

class HomeManagerImpl: HomeManager {
	
	private let sessionManager: Session
	
	private func baseURL() -> URL {
		return UrlConfigurator.urlByAdding()
	}
	
	init(sessionManager: Session) {
		self.sessionManager =  sessionManager
	}
	
	func createHome(name: String, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
		
		let params = ["name": name]
		let endPointURL = baseURL().appendingPathComponent("me/homes")
		guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
			failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
			return
		}
		
		sessionManager.request(request).validate().responseJSON { [weak self] response in
			switch response.result {
			case .success(let data):
				guard let json = JSON(data).dictionaryObject else {
					failure(WSError.failedAddHome)
					return
				}
				let home = Home.init(json: json)
				UserDataManager.shared.currentUser?.homes = [home]
				log.info("Successfully create home")
				success()
			case .failure(let error):
				log.error("Failed to add home - \(error)")
				if let error = error as? URLError, error.code == URLError.notConnectedToInternet {
					NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
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
	
	
}
