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
    
    var flowDelegate: DelegateFlowEventDelegate?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnStake: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    fileprivate let inputForm = DelegateInputForm()
    
    fileprivate var account: AccountInfo!
    
    deinit {
        Log.d("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .white)
        title = LocalizedString.Wallet.Delegate.delegate        
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
        
        btnStake.setTitle(LocalizedString.Wallet.Delegate.delegate, for: .normal)
        btnHistory.setTitle(LocalizedString.Wallet.Delegate.history, for: .normal)
        
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
        
        Observable.combineLatest([inputForm.cpu.asObservable(),inputForm.net.asObservable()])
                .flatMap(isValidInput(max: account.availableEOS))
                .bind(to: btnStake.rx.isEnabled)
                .disposed(by: bag)

        
//            .disposed(by: bag)
        
    }
    
    private func delegatebw() {
        let cpu = Currency(balance: inputForm.cpu.value)
        let net = Currency(balance: inputForm.net.value)
        
        let accountName = account.account
        
        unlockWallet(pinTarget: self, pubKey: account.pubKey)
            .flatMap { (wallet) -> Observable<JSON> in
                 WaitingView.shared.start()
                return RxEOSAPI.delegatebw(account: accountName, cpu: cpu, net: net, wallet: wallet)
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
        let cpu = inputForm.cpu.value.dot4String
        let net = inputForm.net.value.dot4String
        
        //check validate
        
        //confirm
        DelegatePopup.show(cpu: cpu, net: net, buttonTitle: LocalizedString.Wallet.Delegate.delegate)
            .subscribe(onNext: { [weak self](apply) in
                if apply {
                    self?.delegatebw()
                }
            })
            .disposed(by: bag)
    }
    
    private func isValidInput(max: Double) -> ([String]) -> Observable<Bool> {
        return { inputs in
            let total = inputs
                .compactMap { Double($0) }
                .reduce(0.0) { $0 + $1 }
            
            if total > 0 && total <= max {
                return Observable.just(true)
            } else {
                return Observable.just(false)
            }
        }
        
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
        cpuStaked.text = account.cpuStakedEOS.dot4String + " EOS"
        netStaked.text = account.netStakedEOS.dot4String + " EOS"
        
        let bag = DisposeBag()
        txtCpuQuantity.rx.text.orEmpty
            .subscribe(onNext: { (text) in
                inputForm.cpu.value = text.plainFormatted
            })
            .disposed(by: bag)
        
        txtNetQuantity.rx.text.orEmpty
            .subscribe(onNext: { (text) in
                inputForm.net.value = text.plainFormatted
            })
            .disposed(by: bag)
        
        self.bag = bag
    }
}


struct DelegateInputForm {
    let cpu = Variable<String>("")
    let net = Variable<String>("")
    
    func clear() {
        cpu.value = ""
        net.value = ""
    }
}
