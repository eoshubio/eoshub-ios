//
//  VoteViewController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 21..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class VoteViewController: UIViewController {
    @IBOutlet fileprivate weak var bpListView: UITableView!
    
    private let bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProducers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
    }
    
    private func bindActions() {
        
    }
    
    
    private func refreshProducers() {
        RxEOSAPI.getProducers(limit: 200)
            .subscribe(onNext: { (producers) in
                print(producers)
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: bag)
    }
    
}
