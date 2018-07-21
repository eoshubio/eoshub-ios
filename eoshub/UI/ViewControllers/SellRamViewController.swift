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
    
    var flowDelegate: SellRamFlowEventDelegate?
    
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
                self?.validate()
            }
            .disposed(by: bag)
        
        btnHistory.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToTx(from: nc)
            }
            .disposed(by: bag)
    }
    
    private func handleTransaction() {
        
        let quantity = Int64(inputForm.quantity.value) ?? 0
        let accountName = account.account
        unlockWallet(pinTarget: self, pubKey: account.pubKey)
            .flatMap { (wallet) -> Observable<JSON> in
                WaitingView.shared.start()
                return RxEOSAPI.sellram(account: accountName, bytes: quantity, wallet: wallet)
            }
            .flatMap({ (_) -> Observable<Void> in
                WaitingView.shared.stop()
                //clear form
                self.inputForm.clear()
                //pop
                return Popup.show(style: .success, description: LocalizedString.Tx.success)
            })
            .flatMap { (_) -> Observable<Void> in
                return AccountManager.shared.loadAccounts()
            }
            .subscribe(onNext: { (_) in
                self.flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: nil)
            }, onError: { (error) in
                Log.e(error)
                WaitingView.shared.stop()
                Popup.present(style: .failed, description: "\(error)")
            })
            .disposed(by: bag)
        
    }
    
    private func validate() {
        
        let quantity = Int64(inputForm.quantity.value) ?? 0
        
        RxEOSAPI.getRamPrice()
            .flatMap { (price) -> Observable<Bool> in
                return RamPopup.showForSellRam(bytes: quantity, ramPrice: price.ramPriceKB)
            }
            .subscribe(onNext: { [weak self](apply) in
                if apply {
                    self?.handleTransaction()
                }
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
            cell.configure(account: account, inputForm: inputForm, dotStyle: .none)
            return cell
        }
    }
}


class SellRamAccountCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var lbBalance: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    @IBOutlet fileprivate weak var lbUsed: UILabel!
    @IBOutlet fileprivate weak var lbUsedBalance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configure(account: AccountInfo) {
        lbAvailable.text = LocalizedString.Wallet.Transfer.available + "Ram"
        lbUsed.text = LocalizedString.Wallet.Ram.used
        lbAccount.text = account.account
        lbBalance.text = account.availableRamBytes.prettyPrinted
        lbUsedBalance.text = account.usedRam.prettyPrinted
        lbSymbol.text = "RAM"
    }
    
}
