//
//  RoomManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/12/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Alamofire
import Sync
import SwiftyJSON

protocol RoomManager {
    func createRoom(category: String, name: String, success: @escaping (_ roomId: String) -> Void, failure: @escaping (_ error: Error) -> Void)
    func getRooms(success: (() -> Void)?, failure: ((Error) -> Void)?)
    func deleteRoom(roomId: String, success: (() -> Void)?, failure: ((Error) -> Void)?)
    func updateRoom(roomId: String, category: String, name: String, success: (() -> Void)?, failure: ((Error) -> Void)?)
    func switchRoom(roomId: String, turnOn: Bool, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func manualBoostUpdate(roomId: String, temp: Double, time: Int, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)
    func getRoom(roomId: String, success: @escaping (Room) -> Void, failure: @escaping (_ error: Error) -> Void)
}

class RoomManagerImpl: RoomManager {
    
    private let sessionManager: Session
    
    private func baseURL() -> URL {
        return UrlConfigurator.urlByAdding()
    }
    
    init(sessionManager: Session) {
        self.sessionManager =  sessionManager
    }
    
    func createRoom(category: String, name: String, success: @escaping (_ roomId: String) -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let params = ["category": category,
                      "name": name]
        let endPointURL = baseURL().appendingPathComponent("me/rooms")
        guard let request = URLRequest.postRequestWithJsonBody(url: endPointURL, parameters: params) else {
            failure(RequestError.error(NSLocalizedString("Failed to send request, please try again later", comment: "")))
            return
        }
        
        sessionManager.request(request).validate().responseJSON { [weak self] response in
            switch response.result {
            case .success(let result):
                log.info("Successfully add room")
                guard let json = JSON(result).dictionaryObject else {
                   failure(WSError.failedAddRoom)
                   return
                }
                let room = Room.init(json: json)
                self?.addRoomAtLocal(room: room)
                success(room.id)
            case .failure(let error):
                log.error("Failed to add room - \(error)")
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
    
    func getRooms(success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        log.info("getRooms")
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/rooms"), method: .get) else {
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
                        let decodedJSON = try JSONDecoder().decode([Room].self, from: data)
                        UserDataManager.shared.rooms = decodedJSON
                        success?()
                    } catch {
                        log.info("Get Rooms parsing error: \(error)")
                        failure?(error)
                    }
                case .failure(let error):
                    log.info("Get Rooms fetch error: \(error)")
					let statusCode = response.response?.statusCode
					if statusCode == 403 {
						failure?(WSError.loginSessionExpired)
					} else if statusCode == nil && response.response == nil {
						NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
						failure?(error)
					} else {
						failure?(error)
					}
                }
        }
    }
    
    func getRoom(roomId: String, success: @escaping (Room) -> Void, failure: @escaping (_ error: Error) -> Void) {
        log.info("getRooms")
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/rooms/\(roomId)"), method: .get) else {
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
                        log.info(try JSON(data: data).description)
                        let room = try JSONDecoder().decode(Room.self, from: data)
                        success(room)
                    } catch {
                        log.info("Get Room parsing error: \(error)")
                        failure(error)
                    }
                case .failure(let error):
                    log.info("Get Room fetch error: \(error)")
					let statusCode = response.response?.statusCode
					if statusCode == 403 {
						failure(WSError.loginSessionExpired)
					} else if statusCode == nil && response.response == nil {
						NotificationCenter.default.post(name: .KLDNotConnectedToInternet, object: error)
						failure(error)
					} else {
						failure(error)
					}
                }
        }
    }
    
    func deleteRoom(roomId: String, success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        
        guard let request = try? URLRequest(url: baseURL().appendingPathComponent("me/rooms/\(roomId)"), method: .delete) else {
            assertionFailure()
            DispatchQueue.main.async {
                failure?(WSError.general)
            }
            return
        }
        
        sessionManager.request(request).validate().response {  [weak self] response in
            if let error = response.error {
                log.info("Delete Room error: \(error)")
                failure?(error)
            } else {
                log.info("Delete Room successfull")
                self?.removeRoomAtLocal(roomId: roomId)
                success?()
            }
        }
    }
    
    func updateRoom(roomId: String, category: String, name: String, success: (() -> Void)?, failure: ((Error) -> Void)? = nil) {
        
        let params = ["category": category,
                      "name": name]
        let endPointURL = baseURL().appendingPathComponent("me/rooms/\(roomId)")
        
        sessionManager.request(endPointURL,
                               method: .patch,
                               parameters: params,
                               encoding: JSONEncoding.default)
            .validate()
            .response { [weak self] response in
                if let error = response.error {
                    log.error("Failed updating room, \(error.localizedDescription)")
                    failure?(WSError.failedUpdateRoom)
                } else {
                    log.info("Successfully updated room")
                    self?.updateRoomAtLocal(roomId: roomId, name: name, category: category)
                    success?()
                }
            }
    }
    
    func switchRoom(roomId: String, turnOn: Bool, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void) {
        
        let params = ["turn": turnOn ? "ON" : "OFF"]
        let endPointURL = baseURL().appendingPathComponent("setting/rooms/\(roomId)")
        sessionManager.request(endPointURL,
                               method: .post,
                               parameters: params,
                               encoding: JSONEncoding.default)
            .validate()
            .response { response in
                if let error = response.error {
                    log.error("Failed to change status of Sensor - \(error)")
                    failure(WSError.failedUpdateRoom)
                } else {
                    log.info("Successfully change status of Sensor")
                    success()
                }
        }
    }
    
    func manualBoostUpdate(roomId: String, temp: Double, time: Int, success: @escaping () -> Void, failure: @escaping (_ error: Error) -> Void)  {
        let params = ["temp": temp,
                      "time": time] as [String : Any]
        let endPointURL = baseURL().appendingPathComponent("setting/rooms/\(roomId)/temperature")
        sessionManager.request(endPointURL,
                               method: .post,
                               parameters: params,
                               encoding: JSONEncoding.default)
            .validate()
            .response { response in
                if let error = response.error {
                    log.error("Failed to manual boost update - \(error)")
                    failure(WSError.failedUpdateRoom)
                } else {
                    log.info("Successfully manual boost updated")
                    success()
                }
        }
    }
    
    private func removeRoomAtLocal(roomId: String) {
        guard let indexOfRoom = UserDataManager.shared.rooms.firstIndex(where: { $0.id == roomId }) else { return }
        UserDataManager.shared.rooms.remove(at: indexOfRoom)
    }
    
    private func addRoomAtLocal(room: Room) {
        UserDataManager.shared.rooms.insert(room, at: 0)
    }
    
    private func updateRoomAtLocal(roomId: String, name: String, category: String) {
        guard var room = UserDataManager.shared.roomWith(roomId: roomId) else { return }
        room.name = name
        room.category = category
        guard let indexOfRoom = UserDataManager.shared.rooms.firstIndex(where: { $0.id == roomId }) else { return }
        UserDataManager.shared.rooms.remove(at: indexOfRoom)
        UserDataManager.shared.rooms.insert(room, at: indexOfRoom)
    }
    
}
