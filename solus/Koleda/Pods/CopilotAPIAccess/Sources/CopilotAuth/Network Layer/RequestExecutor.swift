//
//  RequestExecutor.swift
//  CopilotAuth
//
//  Created by yulia felberg on 10/2/17.
//  Copyright © 2017 Zemingo. All rights reserved.
//

import Foundation
import Moya
import CopilotLogger

//MARK: Default implementation

class RequestExecutor <T:TargetType> {
    
    let sequentialExecutionHelper: MoyaSequentialExecutionHelper
    
    init(sequentialExecutionHelper: MoyaSequentialExecutionHelper){
        self.sequentialExecutionHelper = sequentialExecutionHelper
    }
    
    
    func executeRequest(target: T, completion: @escaping RequestExecutorClosure) {
        executeRequest(target: target, shouldRetry: true, completion: completion)
    }
    
    func executeRequestWithHeaders(target: T, completion: @escaping RequestExecutorWithHeadersClosure) {
        executeRequestWithHeaders(target: target, shouldRetry: true, completion: completion)
    }
    
    //MARK: Inheritance
    
    func executeRequestWithHeaders(target: T, shouldRetry: Bool, completion: @escaping RequestExecutorWithHeadersClosure) {
        let provider = createMoyaProvider()
        // less than user initiated can take minutes!!! we hsould even consider user interactive, maybe as a parameter
        
        let asyncOperation = MoyaAsyncOperation(provider: provider, target: target) { [weak self] (moyaResult) in
            var requestExecutorResponse: RequestExecutorWithHeadersResponse
            
            switch moyaResult {
            case .failure(let moyaError):
                //TODO:
                //expand the error we return to the app, according to the content of Moya.Error
                requestExecutorResponse = .failure(error: .communication(error: moyaError))
                ZLogManagerWrapper.sharedInstance.logDebug(message: "got failure in moyaResult")
                
            case .success(let response):
                ZLogManagerWrapper.sharedInstance.logDebug(message: "got success in moyaResult")
                
                if let serverError = self?.errorFromMoyaResponse(response) {
                    ZLogManagerWrapper.sharedInstance.logDebug(message: "Converted response to ServerError (\(response) --> \(serverError)")
                    
                    requestExecutorResponse = .failure(error: serverError)
                }
                else {
                    do {
                        if let dict = try response.mapJSON(failsOnEmptyData: false) as? [String: Any] {
                            requestExecutorResponse = .success(HttpResponse(headers: response.response?.allHeaderFields as? [String : Any], body: dict))
                        }
                        else {
                            requestExecutorResponse = .success(HttpResponse(body: [:]))
                        }
                    }
                    catch {
                        ZLogManagerWrapper.sharedInstance.logError(message: "failed to parse response with response : \(response)")
                        requestExecutorResponse = .failure(error: .generalError(message: "failed to parse response with response : \(response)"))
                        
                        //TODO:
                        //Remove general error from the system. Instead, return the object "InternalError" with a message.
                    }
                }
            }
            
            if let _ = self {
                self?.handleCompletion(completion, target: target, shouldRetry: shouldRetry, response: requestExecutorResponse)
            }
            else {
                ZLogManagerWrapper.sharedInstance.logWarning(message: "Completion won't be handled since self is nil")
            }
        }
        sequentialExecutionHelper.queue.addOperation(asyncOperation)
    }
    
    func executeRequest(target: T, shouldRetry: Bool, completion: @escaping RequestExecutorClosure) {
        executeRequestWithHeaders(target: target, shouldRetry: shouldRetry) { (response) in
            switch response {
            case .success(let response):
                completion(.success(response.body))
            case .failure(let error):
                completion(.failure(error: error))
            }
        }
    }
    
    func handleCompletion(_ completion: @escaping RequestExecutorWithHeadersClosure, target:T, shouldRetry: Bool, response: RequestExecutorWithHeadersResponse) {
        completion(response)
    }
    
    //TODO: networkLoggerPlugin should be always part of the provider, and it should be modified at one place only:
    //Create new func createAdditionalPlugins with empty implementation. Subclasses of this class will implemenet createAdditionalPlugins (return array of Plugins)
    //createMoyaProvider WON'T be overriden anymore!
    //in createMoyaProvider should be a call to createAdditionalPlugins, and combining the returned plugins with networkLoggerPlugin
    
    func createMoyaProvider() -> MoyaProvider<T> {
        let networkLoggerPlugin = createMoyaPlugins()
        
        return MoyaProvider<T>(plugins: networkLoggerPlugin)
    }
    
    
    func createMoyaPlugins() -> [PluginType] {
        var plugins: [PluginType] = [NetworkLoggerPlugin(configuration: .init(formatter: .init(),logOptions: .verbose))]

        let bundle = Bundle(for: type(of: self))
        let sdkVersionPlugin = SdkVersionPlugin(fromBundle: bundle)
        plugins.append(sdkVersionPlugin)
        
        return plugins
    }
    
    private func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
    
    //MARK: Error handling
    
    private func errorFromMoyaResponse(_ response: Moya.Response) -> ServerError? {
         do {
            if let json = try response.mapJSON(failsOnEmptyData: false) as? [String: Any]{
                 return ServerError.serverErrorFromStatusCode(response.statusCode, json)
            }
        }
        catch{
            ZLogManagerWrapper.sharedInstance.logError(message: "Failed to parse the response from the server. Reponse: \(response)")
        }
        return ServerError.serverErrorFromStatusCode(response.statusCode, nil)
    }
}
