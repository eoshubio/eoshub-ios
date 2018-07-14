//
//  SendCurrencyViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class SendCurrencyViewController: TextInputViewController {
    
    var flowDelegate: SendFlowEventDelegate?
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var btnSend: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    var account: EOSAccountViewModel!
    var symbol: String!
    
    let sendForm = SendForm()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = LocalizedString.Wallet.send
        showNavigationBar(with: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
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
        
        btnSend.rx.singleTap
            .bind { [weak self] in
                self?.transfer()
            }
            .disposed(by: bag)
    }
    
    func configure(account: EOSAccountViewModel, symbol: String) {
        self.account = account
        self.symbol = symbol
    }
    
    func transfer() {
        //TODO: validation account
        //TODO: validate available EOS
        authentication(showAt: self)
            .flatMap { [weak self](validated) -> Observable<JSON> in
                guard let strongSelf = self else { return  Observable.error(EOSErrorType.invalidState) }
                
                let wallet = Wallet(key: strongSelf.account.pubKey)
                
                return RxEOSAPI.sendCurrency(from: strongSelf.account.account,
                                             to: strongSelf.sendForm.account.value,
                                             quantity: strongSelf.sendForm.quantityCurrency(symbol: strongSelf.symbol),
                                             memo: strongSelf.sendForm.memo.value,
                                             wallet: wallet)
            }
            .flatMap({ (_) -> Observable<AccountInfo> in
                return AccountManager.shared.loadAccounts()
            })
            .subscribe(onNext: { (_) in
                
            }, onError: { (error) in
                Log.e(error)
            }, onCompleted: {
                
            })
            .disposed(by: bag)
        
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
            cell.configure(account: account, symbol: symbol)
            return cell
            
        } else {
            cellId = "SendInputFormCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SendInputFormCell else { preconditionFailure() }
            cell.configure(form: sendForm, symbol: symbol)
            return cell
        }
    }
    
}


class SendMyAccountCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var lbAvailable: UILabel!
    @IBOutlet fileprivate weak var lbBalance: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbAvailable.text = LocalizedString.Wallet.Transfer.availableEOS
    }
    
    
    func configure(account: EOSAccountViewModel, symbol: String) {
        lbAccount.text = account.account
        lbBalance.text = account.availableEOS.dot4String
        lbSymbol.text = symbol
    }
    
}

class SendInputFormCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet fileprivate weak var lbSendTo: UILabel!
    @IBOutlet fileprivate weak var btnPaste: UIButton!
    @IBOutlet fileprivate weak var btnQRCode: UIButton!
    @IBOutlet fileprivate weak var txtAcount: UITextField!
    @IBOutlet fileprivate weak var lbMemo: UILabel!
    @IBOutlet fileprivate weak var lbMemoDesc: UILabel!
    @IBOutlet fileprivate weak var txtMemo: UITextField!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var txtQuantity: UITextField!
    
    var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lbSendTo.text = LocalizedString.Wallet.Transfer.sendTo
        lbMemo.text = LocalizedString.Wallet.Transfer.memo
        lbMemoDesc.text = LocalizedString.Wallet.Transfer.memoDesc
        lbQuantity.text = LocalizedString.Wallet.Transfer.quantity
        
        txtAcount.delegate = self
        txtMemo.placeholder = LocalizedString.Wallet.Transfer.memo
        txtMemo.delegate = self
        txtQuantity.delegate = self
        
        btnPaste.setTitle(LocalizedString.Common.paste, for: .normal)
        
        clearForm()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(form: SendForm, symbol: String) {
        let placeHolder = String(format: LocalizedString.Wallet.Transfer.accountPlaceholder, symbol)
        txtAcount.placeholder = placeHolder
        let bag = DisposeBag()
        txtAcount.rx.text
            .subscribe( { (text) in
                if let input = text.element as? String {
                    form.account.value = input
                }
        })
        .disposed(by: bag)
   
        txtMemo.rx.text
            .subscribe( { (text) in
                if let input = text.element as? String {
                    form.memo.value = input
                }
            })
            .disposed(by: bag)
   
        txtQuantity.rx.text
            .subscribe( { (text) in
                if let input = text.element as? String, let quantity = Double(input) {
                    form.quantity.value = quantity
                }
            })
            .disposed(by: bag)
        
        self.bag = bag
    }
    
    fileprivate func clearForm() {
        txtAcount.text = nil
        txtMemo.text = nil
        txtQuantity.text = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case txtAcount:
            txtMemo.becomeFirstResponder()
        default:
            break//endEditing(true)
        }
        return true
    }
}

struct SendForm {
    let quantity = Variable<Double>(0)
    let account = Variable<String>("")
    let memo = Variable<String>("")
    
    func quantityCurrency(symbol: String) -> Currency {
        let currency = String(quantity.value) + " " + symbol
        return Currency(currency: currency)!
    }
}


