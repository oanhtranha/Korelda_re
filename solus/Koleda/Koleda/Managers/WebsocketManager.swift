//
//  WebsocketManager.swift
//  Koleda
//
//  Created by Oanh tran on 9/10/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import UIKit
import StompClientLib
import SwiftyJSON

enum SocketKeyName : String {
    case HUMIDITY
    case BATTERY
    case TEMPERATURE
    case ROOM_STATUS
}

struct WSDataItem: Decodable {
    let id : String
    var name: String
    var value: Any
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case value = "value"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        if self.name == SocketKeyName.ROOM_STATUS.rawValue {
            self.value = try container.decode(Bool.self, forKey: .value)
        } else {
            self.value = try container.decode(String.self, forKey: .value)
        }
    }
}

protocol WebsocketManagerDelegate: class {
    func refeshAtRoom(with newData: WSDataItem)
}
class  WebsocketManager: NSObject {
    var socketClient = StompClientLib()
    weak var delegate: WebsocketManagerDelegate?
    static let shared :  WebsocketManager = {
        let instance =  WebsocketManager()
        return instance
    }()
    
    func connect() {
        log.info("connecting to Socket")
        let headers =
            ["access_token": LocalAccessToken.restore()!,
             "accept-version": "1.1,1.0", "heart-beat":"10000,10000"]
        guard let url = NSURL(string: UrlConfigurator.socketUrlString()) else {
            return
        }
        socketClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL) , delegate: self, connectionHeaders: headers)
        
    }
    
    func joinTopicOfUser() {
        if let userId = UserDataManager.shared.currentUser?.id {
            let headers = ["id":"sub-0"]
            socketClient.subscribeWithHeader(destination: "/ws/topic/\(userId)", withHeader: headers)
        }
    }
}

extension  WebsocketManager: StompClientLibDelegate {
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        log.info("Received Data WebSocket: \(stringBody)")
        guard let stringData = stringBody else {
            return
        }
        do {
            let data = stringData.data(using: .utf8)!
            let decodedJSON = try JSONDecoder().decode(WSDataItem.self, from: data)
            updateData(data: decodedJSON)
            
        } catch {
            log.info("Get parsing error: \(error)")
        }
        
    }
    
    private func updateData(data: WSDataItem) {
        if [SocketKeyName.TEMPERATURE.rawValue, SocketKeyName.BATTERY.rawValue, SocketKeyName.HUMIDITY.rawValue, SocketKeyName.ROOM_STATUS.rawValue].contains(data.name) {
            delegate?.refeshAtRoom(with: data)
        }
    }
    
    func stompClientDidDisconnect(client: StompClientLib!) {
        
    }
    
    func stompClientDidConnect(client: StompClientLib!) {
        joinTopicOfUser()
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        
    }
    
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        //        socketClient.send
    }
    
    func serverDidSendPing() {
        
    }
}
