//
//  RequestExecutorClosure.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation

typealias RequestExecutorClosure =  (RequestExecutorResponse) -> Void
typealias RequestExecutorResponse = Response<[String: Any], ServerError>

typealias RequestExecutorWithHeadersClosure =  (RequestExecutorWithHeadersResponse) -> Void
typealias RequestExecutorWithHeadersResponse = Response<HttpResponse, ServerError>

class HttpResponse {
    let headers: [String: Any]?
    let body: [String: Any]
    
    init(headers: [String: Any]? = nil, body: [String: Any]) {
        self.body = body
        self.headers = headers
    }
}
