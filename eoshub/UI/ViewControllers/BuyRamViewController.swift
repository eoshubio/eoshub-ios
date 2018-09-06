//
//  BuyRamViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 16..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BuyRamViewController: BaseViewController {
    
    var flowDelegate: BuyRamFlowEventDelegate?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnStake: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    fileprivate let inputForm = RamInputForm()
    
    fileprivate var rx_isEnabled = Variable<Bool>(false)
    
    fileprivate var account: AccountInfo!
    
    deinit {
        Log.d("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .white, bgColor: .basePurple)
        title = LocalizedString.Wallet.Ram.buyram
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
        
        btnStake.setTitle(LocalizedString.Wallet.Ram.buyram, for: .normal)
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
        
        inputForm.quantity.asObservable()
            .flatMap(isValidInput(max: account.availableEOS))
            .bind(to: rx_isEnabled)
            .disposed(by: bag)
        
        rx_isEnabled
            .asObservable()
            .bind(to: btnStake.rx.isEnabled)
            .disposed(by: bag)
        
        inputForm.transaction
            .bind { [weak self] in
                self?.validate()
            }
            .disposed(by: bag)
        
    }
    
    private func handleTransaction() {

        let quantity = Currency(balance: inputForm.quantity.value, token: .eos)
        let accountName = account.account
        
        let wallet = Wallet(key: account.pubKey, parent: self)
        
        WaitingView.shared.start()
        RxEOSAPI.buyram(account: accountName, quantity: quantity, wallet: wallet,
                        authorization: Authorization(actor: account.account, permission: account.permission))    
            .flatMap({ (_) -> Observable<Void> in
                //clear form
                self.inputForm.clear()
                //pop
                return Popup.show(style: .success, description: LocalizedString.Tx.success)
            })
            .flatMap { (_) -> Observable<Void> in
                return AccountManager.shared.loadAccounts()
            }
            .subscribe(onNext: { (_) in
                EHAnalytics.trackEvent(event: .buy_ram)
                self.flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: nil)
            }, onError: { (error) in
                guard let error = error as? PrettyPrintedPopup else { return }
                error.showPopup()
            }) {
                WaitingView.shared.stop()
            }
            .disposed(by: bag)

    }
    
    private func isValidInput(max: Double) -> (String) -> Observable<Bool> {
        return { inputString in
            let input = Double(inputString) ?? 0
            if input > 0 && input <= max {
                return Observable.just(true)
            } else {
                return Observable.just(false)
            }
        }
        
    }
    
    private func validate() {
        
         let quantity = Currency(balance: inputForm.quantity.value, token: .eos)
        WaitingView.shared.start()
        RxEOSAPI.getRamPrice()
            .flatMap { (price) -> Observable<Bool> in
                return RamPopup.showForBuyRam(quantity: quantity.quantity, ramPrice: price.ramPriceKB)
            }
            .subscribe(onNext: { [weak self](apply) in
                if apply {
                    self?.handleTransaction()
                }
            }) {
                WaitingView.shared.stop()
            }
            .disposed(by: bag)
        
    }
    
}

extension BuyRamViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellId = ""
        if indexPath.row == 0 {
            cellId = "MyAccountCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SendMyAccountCell else { preconditionFailure() }
            let balance = Currency(balance: account.availableEOS, token: .eos)
            cell.configure(account: account, balance: balance)
            return cell
            
        } else {
            cellId = "RamInputFormCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? RamInputFormCell else { preconditionFailure() }
            cell.configure(account: account, inputForm: inputForm, dotStyle: .dot4,
                           title: LocalizedString.Wallet.Ram.buyram, available: rx_isEnabled.asObservable())
            return cell
        }
    }
}


class RamInputFormCell: TransactionInputFormCell {
    @IBOutlet fileprivate weak var ramBytes: UILabel!
    @IBOutlet fileprivate weak var txtQuantity: FormattedNumberField!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var lbWarning: UILabel!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    
    private func setupUI() {
        lbQuantity.text = LocalizedString.Wallet.Transfer.quantity
        txtQuantity.addDoneButtonToKeyboard(myAction: #selector(self.txtQuantity.resignFirstResponder))
        lbWarning.text = LocalizedString.Wallet.Ram.warning
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(account: AccountInfo, inputForm: RamInputForm, dotStyle: FormattedNumberField.DotStyle = .dot4,
                   title: String, available: Observable<Bool>) {
        ramBytes.text = account.availableRamBytes.prettyPrinted + " Bytes"
        
        let bag = DisposeBag()
        txtQuantity.style = dotStyle
        txtQuantity.rx.text.orEmpty
            .subscribe(onNext: { (text) in
                inputForm.quantity.value = text.plainFormatted
            })
            .disposed(by: bag)
        
        txtQuantity.inputAccessoryView = makeTransactionButtonToKeyboard(title: title,
                                                                         form: inputForm, bag: bag, available: available)
        
        self.bag = bag
    }
}

struct RamInputForm: TransactionForm {
    let quantity = Variable<String>("")
    
    let transaction = PublishSubject<Void>()
    
    func clear() {
        quantity.value = ""
    }
}
