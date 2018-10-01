//
//  EOSAPITest.swift
//  eoshubTests
//
//  Created by kein on 01/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import XCTest
@testable import eoshub
@testable import Pods_eoshub
@testable import RxSwift


class EOSAPITest: XCTestCase {
    
    private let bag = DisposeBag()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetInfo() {
        
        let expectation = XCTestExpectation(description: "Get information of EOS chain")
        
        eoshub.EOSAPI.Chain.get_info
            .responseJSON(parameter: nil)
            .subscribe(onNext: { (json) in
                XCTAssertNotNil(json, "Response data is nil")
            }, onError: { (error) in
                XCTAssert(false, error.localizedDescription)
            }, onCompleted: {
                expectation.fulfill()
            }) {
                
            }
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testAllNodesAreAlive() {
        
        let expectation = XCTestExpectation(description: "Check if all nodes are alive.")
        
        struct HostCheck: RxAPIRequest {
            let host: String
            var url: String {
                return host
            }
        }
        
        let mainChainId = "aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906"
        
        let hosts = eoshub.Config.apiServers
            .map { $0 + "/v1/chain/get_info" }
            .map(HostCheck.init)
        
        var live = [HostCheck]()
        var dead = [HostCheck]()
        
        hosts.forEach { (host) in
            host.responseJSON(parameter: nil)
                .timeout(3.0, scheduler: MainScheduler.asyncInstance)
                .subscribe(onNext: { (json) in
                    if let chainId = json.string(for: "chain_id"), chainId == mainChainId {
                        live.append(host)
                    } else {
                        dead.append(host)
                    }
                }, onError: { (error) in
                    dead.append(host)
                }, onCompleted: {
                    
                }, onDisposed: {
                    if live.count + dead.count == hosts.count {
                        expectation.fulfill()
                    }
                })
                .disposed(by: bag)
        }
        
        wait(for: [expectation], timeout: 20.0)
        
        XCTAssertEqual(live.count, hosts.count, "List of Dead Servers: \(dead)")
    }
    
    func testCheckUnknownKey() {
        let expectation = XCTestExpectation(description: "Account duplication check")
        let testName = "afmekwlfd2e4"
        RxEOSAPI.getAccount(name: testName)
            .subscribe(onNext: { (account) in
                //failed
                    XCTAssert(false, "\(account)")
                }, onError: { (error) in
                    guard let error = error as? EOSResponseError else { return }
                    if error.isUnknownKey {
                       //success
                        expectation.fulfill()
                    } else {
                        //exception
                       XCTAssert(false, error.localizedDescription)
                    }
            }) {
                
            }
            .disposed(by: bag)
        
        wait(for: [expectation], timeout: 10.0)
    }
   
}
