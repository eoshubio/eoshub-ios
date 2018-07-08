//
//  SettingViewController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView?
    
    private let settingData = SettingData()
    
    private let bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "설정"
        navigationController?.isNavigationBarHidden = false
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        tableView?.dataSource = settingData
        tableView?.delegate = settingData
    }
    
    
   
}

class SettingData: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let bag = DisposeBag()
    
    let data: [SettingItem] = [.airDropEOS, .deleteDB, .signTest]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        
        let item = data[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.selectionStyle = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = data[indexPath.row]
        
        switch item {
        case .airDropEOS:
            airDropEOS()
        case .deleteDB:
            DB.shared.deleteAll()
            exit(0)
        case .signTest:
            break
        }
        
    }
    
    fileprivate func airDropEOS() {
        guard let wallet = WalletManager.shared.getWallet() else { return }
        RxEOSAPI.sendCurrency(from: EOSHub.account, to: wallet.name, quantity: Currency(currency: "7.0000 EOS")!, memo: "7 airdrop")
            .subscribe(onNext: { (json) in
                print(json)
                WalletManager.shared.refreshBalance()
            }, onError: { (error) in
                print(error)
            })
            .disposed(by: bag)
    }
}

enum SettingItem {
    case airDropEOS
    case deleteDB
    case signTest
    
    var title: String {
        switch self {
        case .airDropEOS:
            return "테스트용 EOS 받기"
        case .deleteDB:
            return "DB 날리고 종료하기"
        case .signTest:
            return "서명 테스트하기"
        }
    }
}


