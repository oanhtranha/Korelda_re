//
//  SdkVersionPlugin.swift
//  CopilotAPIAccess
//
//  Created by Revital Pisman on 31/10/2019.
//  Copyright © 2019 Zemingo. All rights reserved.
//

import Foundation
import Moya

internal struct SdkVersionPlugin: PluginType {

    private let sdkBundle: Bundle
    
    init(fromBundle sdkBundle: Bundle) {
        self.sdkBundle = sdkBundle
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        
        var request = request
        
        let sdkVersion = sdkBundle.infoDictionary?[String.bundleShortVersionKey] as? String
        if let sdkVersion = sdkVersion {
            request.addValue(sdkVersion, forHTTPHeaderField: String.copilotSDKVersionForApiHeaderKey)
        }
        
        return request
    }
}
