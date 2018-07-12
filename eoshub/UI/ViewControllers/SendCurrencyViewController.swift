//
//  SendCurrencyViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class SendCurrencyViewController: TextInputViewController {
    
    var flowDelegate: SendFlowEventDelegate?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnSend: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    var account: EOSWalletViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = LocalizedString.Wallet.send
        showNavigationBar(with: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        contentsScrollView = tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        
        btnSend.setTitle(LocalizedString.Wallet.Transfer.transfer, for: .normal)
        btnHistory.setTitle(LocalizedString.Wallet.Transfer.history, for: .normal)
    }
    
    private func bindActions() {
        btnHistory.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToTx(from: nc)
            }
            .disposed(by: bag)
    }
    
    func configure(account: EOSWalletViewModel) {
        self.account = account
    }
    
}

extension SendCurrencyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellId = ""
        if indexPath.row == 0 {
            cellId = "SendMyAccountCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SendMyAccountCell else { preconditionFailure() }
            cell.configure(account: account)
            return cell
            
        } else {
            cellId = "SendInputFormCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SendInputFormCell else { preconditionFailure() }
            return cell
        }
    }
    
}


class SendMyAccountCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var lbBalance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbAvailable.text = LocalizedString.Wallet.Transfer.availableEOS
    }
    
    
    func configure(account: EOSWalletViewModel) {
        lbAccount.text = account.account
        lbBalance.text = account.availableEOS.dot4String
    }
    
}

class SendInputFormCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbSendTo: UILabel!
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var btnPaste: UIButton!
    @IBOutlet fileprivate weak var btnQRCode: UIButton!
    @IBOutlet fileprivate weak var txtAcount: UITextField!
    @IBOutlet fileprivate weak var lbMemo: UILabel!
    @IBOutlet fileprivate weak var lbMemoDesc: UILabel!
    @IBOutlet fileprivate weak var txtMemo: UITextField!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var txtQuantity: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbSendTo.text = LocalizedString.Wallet.Transfer.sendTo
        lbAccount.text = LocalizedString.Wallet.Transfer.accountPlaceholder
        lbMemo.text = LocalizedString.Wallet.Transfer.memo
        lbMemoDesc.text = LocalizedString.Wallet.Transfer.memoDesc
        lbQuantity.text = LocalizedString.Wallet.Transfer.quantity
        
        txtAcount.placeholder = LocalizedString.Wallet.Transfer.accountPlaceholder
        txtMemo.placeholder = LocalizedString.Wallet.Transfer.memo
        
        btnPaste.setTitle(LocalizedString.Common.paste, for: .normal)
        
        clearForm()
    }
    
    
    fileprivate func clearForm() {
        txtAcount.text = nil
        txtMemo.text = nil
        txtQuantity.text = "0"
    }
    
    
}
