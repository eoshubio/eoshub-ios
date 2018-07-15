//
//  DelegateViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class DelegateViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnStake: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    fileprivate let inputForm = DelegateInputForm()
    
    fileprivate var account: AccountInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .white)
        title = LocalizedString.Wallet.Delegate.delegate
        
        let backItem = UIBarButtonItem()
        backItem.title = "1"
        navigationController?.navigationItem.backBarButtonItem = backItem
        
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
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        btnStake.setTitle(LocalizedString.Wallet.Delegate.delegate, for: .normal)
        btnHistory.setTitle(LocalizedString.Wallet.Delegate.history, for: .normal)
    }
    
    private func bindActions() {
        
        btnStake.rx.singleTap
            .bind { [weak self] in
                self?.delegatebw()
            }
            .disposed(by: bag)
        
    }
    
    private func delegatebw() {
        
        let cpu = Currency(balance: inputForm.cpu.value, symbol: .eos)
        let net = Currency(balance: inputForm.net.value, symbol: .eos)
        let accountName = account.account
        unlockWallet(pinTarget: self, pubKey: account.pubKey)
            .flatMap { (wallet) -> Observable<JSON> in
                return RxEOSAPI.delegatebw(account: accountName, cpu: cpu, net: net, wallet: wallet)
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

extension DelegateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellId = ""
        if indexPath.row == 0 {
            cellId = "MyAccountCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SendMyAccountCell else { preconditionFailure() }
            let balance = Currency(balance: account.totalEOS, symbol: .eos)
            cell.configure(account: account, balance: balance)
            return cell
            
        } else {
            cellId = "DelegateInputFormCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? DelegateInputFormCell else { preconditionFailure() }
            cell.configure(account: account, inputForm: inputForm)
            return cell
        }
    }
}


class DelegateInputFormCell: UITableViewCell {
    @IBOutlet fileprivate weak var cpuStaked: UILabel!
    @IBOutlet fileprivate weak var netStaked: UILabel!
    @IBOutlet fileprivate weak var txtCpuQuantity: UITextField!
    @IBOutlet fileprivate weak var txtNetQuantity: UITextField!
    @IBOutlet fileprivate weak var lbCpuQuantity: UILabel!
    @IBOutlet fileprivate weak var lbNetQuantity: UILabel!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    
    private func setupUI() {
        lbCpuQuantity.text = LocalizedString.Wallet.Transfer.quantity
        lbNetQuantity.text = LocalizedString.Wallet.Transfer.quantity
        txtCpuQuantity.addDoneButtonToKeyboard(myAction: #selector(self.txtCpuQuantity.resignFirstResponder))
        txtNetQuantity.addDoneButtonToKeyboard(myAction: #selector(self.txtNetQuantity.resignFirstResponder))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(account: AccountInfo, inputForm: DelegateInputForm) {
        cpuStaked.text = account.cpuStakedEOS.dot4String
        netStaked.text = account.netStakedEOS.dot4String
        
        let bag = DisposeBag()
        txtCpuQuantity.rx.text.orEmpty
            .subscribe(onNext: { (text) in
                inputForm.cpu.value = Double(text) ?? 0
            })
            .disposed(by: bag)
        
        txtNetQuantity.rx.text.orEmpty
            .subscribe(onNext: { (text) in
                inputForm.net.value = Double(text) ?? 0
            })
            .disposed(by: bag)
        
        self.bag = bag
    }
}


struct DelegateInputForm {
    let cpu = Variable<Double>(0)
    let net = Variable<Double>(0)
}
