//
//  ScenicMapTests.swift
//  ScenicMapTests
//
//  Created by Yi JIANG on 12/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import ObjectMapper
import CoreLocation
@testable import ScenicMap

class ScenicMapTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    func testScenicLocationServerWithCorrectApi() {
        let apiClient = ApiClient()
        let sydneyLocation = getSydneyLocation()
        apiClient.fetchRestfulApi(.scenicLocations(sydneyLocation)).subscribe(onNext: { status in
            switch status {
            case .success(let apiResponse):
                let slResponse = apiResponse as! SLResponse
                let locations = slResponse.locations
                XCTAssertTrue(locations != nil)
                XCTAssertTrue(locations!.count > 0)
            //MARK: We can test more key:value to verify the decode logic is right.
            case .fail(let error):
                print(error.errorDescription ?? "Faild to load ScenicLocation data")
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
   
    func testDecodeApiClientSuccessByMockData(){
        let mockApiClient = MockApiClient()
        mockApiClient.jsonFileName = .slResponse
        let sydneyLocation = getSydneyLocation()
        MockApiClient().fetchRestfulApi(.scenicLocations(sydneyLocation))
            .subscribe(onNext: { status in
                switch status {
                case .success(let apiResponse):
                    let slResponse = apiResponse as! SLResponse
                    let locations = slResponse.locations
                    XCTAssertTrue(locations != nil)
                    XCTAssertTrue(locations!.count > 0)
                case .fail(let error):
                    print(error.errorDescription ?? "Faild to load weather data")
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    func testDecodeApiClientSuccessByEmptyMockData(){
        let mockApiClient = MockApiClient()
        mockApiClient.jsonFileName = .slResponse_empty
        let sydneyLocation = getSydneyLocation()
        mockApiClient.fetchRestfulApi(.scenicLocations(sydneyLocation)).subscribe(onNext: { status in
            switch status {
            case .success(let apiResponse):
                let slResponse = apiResponse as! SLResponse
                let locations = slResponse.locations
                XCTAssertTrue(locations != nil)
                XCTAssertTrue(locations!.count == 0)
            case .fail(let error):
                print(error.errorDescription ?? "Faild to load error data")
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
    }
    
}

extension ScenicMapTests {
    func getSydneyLocation() -> CLLocation {
        let sydLatitude = CLLocationDegrees(-33.873692)
        let sydLongitude = CLLocationDegrees(151.206768)
        return CLLocation.init(latitude: sydLatitude, longitude: sydLongitude)
    }
}

class MockApiClient: ApiClient {
    
    enum JsonFileName: String {
        case slResponse = "MockScenicLocations"
        case slResponse_empty = "MockScenicLocations_empty"
    }
    
    var jsonFileName = JsonFileName.slResponse
    
    override func fetchRestfulApi(_ config: ApiConfig) -> Observable<RequestStatus> {
        return super.fetchRestfulApi(config)
    }
    
    //Use mock response data based on the
    override func networkRequest(_ config: ApiConfig, completionHandler: @escaping (([String : Any]?, RequestError?) -> Void)) {
        guard let json = JsonFileLoader.loadJson(fileName: jsonFileName.rawValue) as? [String: Any] else {
            completionHandler(nil, RequestError("Parse Weather information failed."))
            return
        }
        completionHandler(json, nil)
    }
}

class JsonFileLoader {
    
    class func loadJson(fileName: String) -> Any? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "json") {
            if let data = NSData(contentsOf: url) {
                do {
                    return try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                } catch {
                    print("Error!! Unable to parse  \(fileName).json")
                }
            }
            print("Error!! Unable to load  \(fileName).json")
        } else {
            print("invalid url")
        }
        return nil
    }
}

