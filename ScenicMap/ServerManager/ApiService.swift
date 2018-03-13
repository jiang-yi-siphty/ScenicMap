//
//  ApiService.swift
//  GoodDay
//
//  Created by Yi JIANG on 12/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

enum RequestStatus {
    case success(AnyObject?)
    case fail(RequestError)
}

struct RequestError : LocalizedError {
    var errorDescription: String? { return mMsg }
    var failureReason: String? { return mMsg }
    var recoverySuggestion: String? { return "" }
    var helpAnchor: String? { return "" }
    private var mMsg : String
    
    init(_ description: String) {
        mMsg = description
    }
}

enum  ApiConfig {
    case scenicLocations(CLLocation)
    
    fileprivate static let scenicBaseUrl = "http://bit.ly"
    
    var urlPath: String {
        switch self {
        case .scenicLocations(_):
            return "/test-locations"
        }
    }

    var method: String {
        switch self {
        case .scenicLocations(_):
            return "GET"
        }
    }
    
    var header: [String: Any]?{
        switch self {
        case .scenicLocations(_):
            return nil
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .scenicLocations(_):
            return nil
        }
    }
    
    func getFullUrl() -> URL {
        var baseUrl: String!
        switch self {
        case .scenicLocations(_):
            baseUrl = ApiConfig.scenicBaseUrl
        }
        if let url = URL(string: baseUrl + self.urlPath)  {
            return url
        } else {
            return URL(string: baseUrl)!
        }
    }
}

protocol ApiService {
    func fetchRestfulApi(_ config: ApiConfig) -> Observable<RequestStatus>
    func networkRequest(_ config: ApiConfig, completionHandler: @escaping ((_ jsonResponse: [String: Any]?, _ error: RequestError?) -> Void))
}
