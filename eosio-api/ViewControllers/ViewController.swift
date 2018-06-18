//
//  ViewController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 13..
//  Copyright © 2018년 kein. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    fileprivate let bag = DisposeBag()
    
    @IBOutlet weak var testId: UITextField?
    @IBOutlet weak var testBtn: UIButton?
    @IBOutlet weak var testDebugView: UITextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let eosapi = EOSHost.shared
        eosapi.host = "http://175.195.57.102:8888"
//        eosapi.host = "http://192.168.0.12:8888"

        testBtn?.rx.tap
            .subscribe(onNext: { (_) in
                
                RxEOSAPI.getInfo()
                    .subscribe(onNext: { (info) in
                        print(info)
                        self.testDebugView?.text = "\(info)"
                    }, onError: { (error) in
                        print(error)
                    })
                    .disposed(by: self.bag)
                
//                let name = self.testId?.text ?? "testaccount1"
//                self.testId?.resignFirstResponder()
//                self.createAccount(name: name)
            })
            .disposed(by: bag)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createAccount(name: String) {
        RxEOSAPI.createAccount(name: name, authorization: Authorization.eosio)
            .subscribe(onNext: { (json) in
                print(json)
                self.testDebugView?.text = "\(json)"
            }, onError: { (error) in
                print(error)
                self.testDebugView?.text = "\(error)"
            })
            .disposed(by: bag)
//        createAccountTest(name: name)
    }
    
}


//
//    func sendNovaTest() {
//        let testInput0: JSON =
//            ["code": "eosio.token",
//             "action": "transfer",
//             "args": ["from":"keintest1",
//                      "to":"keintest2",
//                      "quantity": "0.3333 NOVA",
//                      "memo": "Remote Sending"
//                ]
//
//        ]
//
//        func getAction(data: String) -> [Any] {
//            return [[
//                "account": "eosio.token",
//                "name": "transfer",
//                "authorization": [
//                    [
//                        "actor": "keintest1",
//                        "permission": "active"
//                    ]
//                ],
//                "data": data
//                ]]
//        }
//
//        var bin: String = ""
//        var block: Block?
//        RxEOSAPI.jsonToBin(json: testInput0)
//            .flatMap({ (binary) -> Observable<BlockInfo> in
//                print(binary.bin)
//                bin = binary.bin
//                return RxEOSAPI.getInfo()
//            })
//            .flatMap { (info) -> Observable<Block> in
//                return RxEOSAPI.getBlock(json: ["block_num_or_id":info.headBlockNum])
//            }
//            .flatMap({ (b) -> Observable<Bool> in
//                block = b
//                return RxEOSAPI.walletUnlock(array: ["default","PW5JRTW8biPkM64mPFJ1T67AQmQ8bsy4cyDGUQ6Qrzp3i8yK96Xvs"])
//            })
//            .flatMap({ (_) -> Observable<SignedTransaction> in
//                let trx: [Any] = [["expiration": block!.timeStamp.addingTimeInterval(180).dateToUTC(),
//                                   "ref_block_num": block!.blockNum,
//                                   "ref_block_prefix": block!.refBlockPrefix,
//                                   "actions": getAction(data: bin),
//                                   "signatures": []],
//                                  ["EOS8Z8SihYeYTkLY35pSPJeaD2zeeC3JZRYVSaghuV8QjUW75TcYf"],
//                                  "cf057bbfb72640471fd910bcb67639c22df9f92470936cddc1ade0e2f2e7dc4f"
//                ]
//                return RxEOSAPI.signTransaction(array: trx)
//            })
//            .flatMap({ (sig) -> Observable<JSON> in
//                let trx: JSON = [
//                    "compression": "none",
//                    "transaction": [
//                        "expiration": sig.expiration,
//                        "ref_block_num": sig.refBlockNum,
//                        "ref_block_prefix": sig.refBlockPrefix,
//                        "context_free_actions": [],
//                        "max_net_usage_words": 0,
//                        "max_cpu_usage_ms": 0,
//                        "delay_sec": 0,
//                        "actions": getAction(data: bin),
//                        "transaction_extensions": []
//                    ],
//                    "signatures": sig.signatures
//                ]
//
//                return RxEOSAPI.pushTransaction(json: trx)
//            })
//            .subscribe(onNext: { (json) in
//                print(json)
//                self.testDebugView?.text = "\(json)"
//            }, onError: { (error) in
//                print(error)
//            })
//            .disposed(by: bag)
//
//
//
//
//    }
//
//}

