//
//  SellRamViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class SellRamViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnStake: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    fileprivate let inputForm = RamInputForm()
    
    fileprivate var account: AccountInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .white)
        title = LocalizedString.Wallet.Ram.sellram
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        btnStake.setTitle(LocalizedString.Wallet.Ram.sellram, for: .normal)
        btnHistory.setTitle(LocalizedString.Wallet.Ram.history, for: .normal)
    }
    
    private func bindActions() {
        
        btnStake.rx.singleTap
            .bind { [weak self] in
                self?.handleTransaction()
            }
            .disposed(by: bag)
        
    }
    
    private func handleTransaction() {
        
        let quantity = Int64(inputForm.quantity.value)
        let accountName = account.account
        unlockWallet(pinTarget: self, pubKey: account.pubKey)
            .flatMap { (wallet) -> Observable<JSON> in
                return RxEOSAPI.sellram(account: accountName, bytes: quantity, wallet: wallet)
            }
            .flatMap { (_) -> Observable<Void> in
                return AccountManager.shared.loadAccounts()
            }
            .subscribe(onError: { (error) in
                Log.e(error)
            })
            .disposed(by: bag)
        
    }
    
}

extension SellRamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellId = ""
        if indexPath.row == 0 {
            cellId = "SellRamAccountCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SellRamAccountCell else { preconditionFailure() }
            cell.configure(account: account)
            return cell
            
        } else {
            cellId = "RamInputFormCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? RamInputFormCell else { preconditionFailure() }
            cell.configure(account: account, inputForm: inputForm)
            return cell
        }
    }
}


class SellRamAccountCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var lbBalance: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configure(account: AccountInfo) {
        lbAvailable.text = LocalizedString.Wallet.Transfer.available + "Ram"
        lbAccount.text = account.account
        lbBalance.text = account.ramBytes.prettyPrinted
        lbSymbol.text = "Bytes"
    }
    
}
