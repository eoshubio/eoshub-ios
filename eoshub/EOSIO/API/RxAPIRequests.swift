//
//  EOSApiRequests.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 13..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol RxAPIRequest {
    var url: String { get }
    
    func response() -> Observable<DefaultDataResponse>
    func response(method: Alamofire.HTTPMethod, string: String) -> Observable<DefaultDataResponse>
    func response(method: Alamofire.HTTPMethod, array: [String]) -> Observable<DefaultDataResponse>
    func response(method: Alamofire.HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) -> Observable<DefaultDataResponse>
    func responseJSON(method: Alamofire.HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) -> Observable<JSON>
    func responseArray(method: Alamofire.HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) -> Observable<[Any]>
    func responseString(method: Alamofire.HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) -> Observable<String>
}

extension RxAPIRequest {
    func response() -> Observable<DefaultDataResponse> {
        return response(method: .get, parameter: nil, encoding: URLEncoding.default)
    }
    func response(method: Alamofire.HTTPMethod = .post, string: String) -> Observable<DefaultDataResponse> {
        return response(method: method, parameter: [StringEncoding.key: string], encoding: StringEncoding.default)
    }
    
    func response(method: Alamofire.HTTPMethod = .post, array: [String]) -> Observable<DefaultDataResponse> {
        return response(method: method, parameter: [ArrayEncoding.key: array], encoding: ArrayEncoding.default)
    }
    
    func response(method: Alamofire.HTTPMethod = .post, parameter: Parameters?, encoding: ParameterEncoding = JSONEncoding.default) -> Observable<DefaultDataResponse> {
        let apiURL = url
        
        return Observable.create { (observer) -> Disposable in
            let request =  Alamofire.request(apiURL, method: method, parameters: parameter, encoding: encoding, headers: [:])
                .response(completionHandler: { (response) in
                    print("Result response: \(response)")
                    observer.onNext(response)
                    observer.onCompleted()
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func responseJSON(method: Alamofire.HTTPMethod = .post, parameter: Parameters?, encoding: ParameterEncoding = JSONEncoding.default) -> Observable<JSON> {
        let apiURL = url
        
        return Observable.create { (observer) -> Disposable in
            let request =  Alamofire.request(apiURL, method: method, parameters: parameter, encoding: encoding, headers: [:])
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let result):
                        print("Result response: \(result)")
                        let json = result as? JSON ?? [:]
                        if let error = EOSResponseError(json: json) {
                            observer.onError(error)
                        } else {
                            observer.onNext(json)
                            observer.onCompleted()
                        }
                    case  .failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
    func responseArray(method: Alamofire.HTTPMethod = .post, parameter: Parameters?, encoding: ParameterEncoding) -> Observable<[Any]> {
        let apiURL = url
        
        return Observable.create { (observer) -> Disposable in
            let request =  Alamofire.request(apiURL, method: method, parameters: parameter, encoding: encoding, headers: [:])
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let result):
                        let array = result as? [Any] ?? []
                        print("Result response: \(array)")
                        observer.onNext(array)
                        observer.onCompleted()
                    case  .failure(let error):
                        observer.onError(error)
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func responseString(method: Alamofire.HTTPMethod, parameter: Parameters?, encoding: ParameterEncoding) -> Observable<String> {
        let apiURL = url
        
        return Observable.create { (observer) -> Disposable in
            let request =  Alamofire.request(apiURL, method: method, parameters: parameter, encoding: encoding, headers: [:])
                .response(completionHandler: { (response) in
                    print("Result response: \(response)")
                    if let data = response.data, let string = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "") {
                        observer.onNext(string)
                        observer.onCompleted()
                    } else {
                        observer.onError(EOSErrorType.emptyData)
                    }
                })
            return Disposables.create {
                request.cancel()
            }
        }
    }
}





struct StringEncoding: ParameterEncoding {
    
    static var `default`: StringEncoding { return StringEncoding() }
    
    static let key = "utf8stringKey"
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        guard let string = parameters?[StringEncoding.key] as? String else { preconditionFailure("Invalid Format: \(String(describing: parameters))") }
        
        let urlencoded = "\"" + string + "\""
        
        request.httpBody = urlencoded.data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

struct ArrayEncoding: ParameterEncoding {
    
    static var `default`: ArrayEncoding { return ArrayEncoding() }
    
    static let key = "stringArrayKey"
    /// The options for writing the parameters as JSON data.
    public let options: JSONSerialization.WritingOptions
    
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        
        guard let parameters = parameters,
            let array = parameters[ArrayEncoding.key] else {
                return request
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: options)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
        } catch {
            throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
        }
        return request
    }
}







