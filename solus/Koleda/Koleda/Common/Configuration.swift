//
//  Configuration.swift
//  Koleda
//
//  Created by Oanh tran on 7/1/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Alamofire

extension URLRequest {
    
    static func postRequestWithJsonBody(url: URL, parameters: [String: Any]) -> URLRequest? {
        var urlRequest: URLRequest? = nil
        var bodyData: Data? = nil
        do {
            urlRequest = try URLRequest(url: url, method: .post, headers: ["Content-Type":"application/json"])
            bodyData = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return nil
        }
        urlRequest?.httpBody = bodyData
        return urlRequest
    }
    
    static func requestWithJsonBody(url: URL, method: HTTPMethod, parameters: [String: Any]) -> URLRequest? {
        var urlRequest: URLRequest? = nil
        var bodyData: Data? = nil
        do {
            urlRequest = try URLRequest(url: url, method: method, headers: ["Content-Type":"application/json"])
            bodyData = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            return nil
        }
        urlRequest?.httpBody = bodyData
        return urlRequest
    }
}



class UrlConfigurator {
    
    private class func baseUrlString() -> String {
        guard let info = Bundle.main.infoDictionary else {
            assert(false, "Failed while reading info from settings")
            return ""
        }
        guard let serverURL = info["SERVER_URL"] as? String else {
            assert(false, "Failed while reading SERVER_URL from settings")
            return ""
        }
        return serverURL
    }
    
    class func mqttUrlString() -> String {
        guard let info = Bundle.main.infoDictionary else {
            assert(false, "Failed while reading info from settings")
            return ""
        }
        guard let mqttServerURL = info["MQTT_SERVER_URL"] as? String else {
            assert(false, "Failed while reading MQTT_SERVER_URL from settings")
            return ""
        }
        return mqttServerURL
    }
    
    class func socketUrlString() -> String {
        guard let info = Bundle.main.infoDictionary else {
            assert(false, "Failed while reading info from settings")
            return ""
        }
        guard let socketURL = info["SOCKET_URL"] as? String else {
            assert(false, "Failed while reading SOCKET_URL from settings")
            return ""
        }
        return socketURL
    }
    
    class func urlByAdding(port:Int = 5525, path: String = "") -> URL {
        assert(port > 0, "Incorrect port value")
        guard let url = URL(string: baseUrlString() + ":\(port)")  else {
            assert(false, "Failed while constructing URL")
            return URL.invalidURL
        }
        return url.appendingPathComponent(path)
    }
    
}
