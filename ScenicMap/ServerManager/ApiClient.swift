//
//  ApiClient.swift
//  GoodDay
//
//  Created by Yi JIANG on 12/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire
import ObjectMapper

class ApiClient: ApiService {
    
    func fetchRestfulApi(_ config: ApiConfig) -> Observable<RequestStatus> {
        return Observable<RequestStatus>.create { observable -> Disposable in
            self.networkRequest(config, completionHandler: { (json, error) in
                guard let json = json else {
                    if let error = error {
                        observable.onNext(RequestStatus.fail(error))
                    } else {
                        observable.onNext(RequestStatus.fail(RequestError("Parse JSON information failed.")))
                    }
                    observable.onCompleted()
                    return
                }
                var response: AnyObject? = nil
                switch config {
                case .scenicLocations(_):
                    response = Mapper<SLResponse>().map(JSON: json)
                }
                if let response = response {
                    observable.onNext(RequestStatus.success(response))
                } else {
                    observable.onNext(RequestStatus.fail(RequestError("Parse JSON information failed.")))
                }
                observable.onCompleted()
            })
            return Disposables.create()
            }.share()
    }
    
    func networkRequest(_ config: ApiConfig, completionHandler: @escaping (([String : Any]?, RequestError?) -> Void)) {
        networkRequestByAlamoFire(config, completionHandler: completionHandler)
//        networkRequestByNSURLSession(config, completionHandler: completionHandler)
    }
}

// Other Network request methods and Response handler
extension ApiClient {
    
    func networkRequestByAlamoFire(_ config: ApiConfig, completionHandler: @escaping ((_ jsonResponse: [String: Any]?, _ error: RequestError?) -> Void)) {
        URLCache.shared.removeAllCachedResponses()
        let url = config.getFullUrl()
        Alamofire.request(url).responseJSON(queue: DispatchQueue.global(), options: .allowFragments) { response in
            guard let json = response.result.value as? [String: Any] else {
                print("Error: \(String(describing: response.result.error))")
                completionHandler(nil, RequestError((response.result.error?.localizedDescription)!))
                return
            }
            print(json.debugDescription)
            completionHandler(json, nil)
        }
    }
    
    func networkRequestByNSURLSession(_ config: ApiConfig, completionHandler: @escaping ((_ jsonResponse: [String: Any]?, _ error: RequestError?) -> Void)) {
        URLCache.shared.removeAllCachedResponses()
        let url = config.getFullUrl()
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, response, error) in
            self.responseHandler(data, error, completionHandler)
        }
        task.resume()
    }
    
    fileprivate func responseHandler(_ data: Data?, _ error: Error?, _ completionHandler: @escaping ((_ jsonResponse: [String: Any]?, _ error: RequestError?) -> Void)){
        if let error = error {
            completionHandler(nil, RequestError(error.localizedDescription))
        } else if let data = data {
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    completionHandler(json, nil)
                } else {
                    completionHandler(nil, RequestError("JSON decode failed!!!"))
                }
            } catch let error {
                completionHandler(nil, RequestError(error.localizedDescription))
            }
        }
    }
}
