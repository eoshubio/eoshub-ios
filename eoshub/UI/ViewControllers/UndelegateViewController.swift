//
//  UndelegateViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

//
//  DelegateViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class UndelegateViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnStake: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    fileprivate var account: AccountInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .white)
        title = LocalizedString.Wallet.Delegate.undelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.dataSource = self
        //        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        btnStake.setTitle(LocalizedString.Wallet.Delegate.undelegate, for: .normal)
        btnHistory.setTitle(LocalizedString.Wallet.Delegate.history, for: .normal)
    }
    
}

extension UndelegateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellId = ""
        if indexPath.row == 0 {
            cellId = "UndelegateMyAccountCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? UndelegateMyAccountCell else { preconditionFailure() }
            let balance = Currency(balance: account.totalEOS, symbol: .eos)
            cell.configure(account: account, balance: balance)
            return cell
            
        } else {
            cellId = "DelegateInputFormCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? DelegateInputFormCell else { preconditionFailure() }
            cell.configure(account: account)
            return cell
        }
    }
}

class UndelegateMyAccountCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var lbBalance: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configure(account: AccountInfo, balance: Currency) {
        lbAvailable.text = LocalizedString.Wallet.Delegate.stakedEOS
        lbAccount.text = account.account
        lbBalance.text = balance.balance
        lbSymbol.text = balance.symbol
    }
    
}
