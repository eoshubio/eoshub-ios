//
//  EOSHubAPITest.swift
//  eoshubTests
//
//  Created by kein on 01/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import XCTest
@testable import eoshub
@testable import Pods_eoshub
@testable import RxSwift
@testable import Alamofire

class EOSHubAPITest: XCTestCase {

    private let bag = DisposeBag()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetTokenList() {
        let expectation = XCTestExpectation(description: "Get token list from eos-hub.io")
        
        eoshub.EOSHubAPI.Token.list
            .responseJSON(method: .get, parameter: nil, encoding: URLEncoding.default)
            .subscribe(onNext: { (json) in
                XCTAssertNotNil(json, "Token list is nil")
                
                let data = json.json(for: "resultData")
                guard let list = data?.arrayJson(for: "tokenList") else { return }
                
                XCTAssertGreaterThan(list.count, 0, "Token list is empty")
                
                expectation.fulfill()
                
            }, onError: { (error) in
                XCTAssert(false, error.localizedDescription)
            })
            .disposed(by: bag)
        
          wait(for: [expectation], timeout: 10.0)
    }
   

}
