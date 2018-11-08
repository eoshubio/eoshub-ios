//
//  TxConfirmViewController.swift
//  eoshub
//
//  Created by kein on 2018. 9. 18..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

struct TxResult {
    let txid: String
    let autoSign: Bool
}

class TxConfirmViewController: BaseTableViewController {
    var flowDelegate: FlowEventDelegate?
    var contract: Contract! {
        didSet {
            items.removeAll()
            let action = contract.action + "@" + contract.code
            items.append(.action(action))
            let args = contract.args.map { (argument) -> CellType in
                let value = argument.value as? String ?? "\(argument.value)"
                return CellType.args(key: argument.key, value: value)
            }
            items += args
            
            let actor = contract.authorization.stringValue
            items.append(.actor(actor))
            items.append(.confirm)
        }
    }
    
    var items: [CellType] = []
    
    fileprivate let form = TxConfirmForm()
    
    fileprivate let autoSignSubject = PublishSubject<Bool>()
    
    fileprivate weak var result: PublishSubject<TxResult>?
    
    fileprivate var autoSignEnabled = false
    
    deinit {
        Log.i("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        showNavigationBar(with: .basePurple, animated: true, largeTitle: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
    }
    
    private func bindActions() {
        
        form.confirm
            .bind(onNext: confirmTx)
            .disposed(by: bag)
        
        form.cancel
            .bind(onNext: cancelled)
            .disposed(by: bag)
        
        autoSignSubject
            .asObserver()
            .bind { [weak self](on) in
                self?.autoSignEnabled = on
            }
            .disposed(by: bag)
        
    }
    
    func configure(contract: Contract, title: String?, result: PublishSubject<TxResult>?) {
        self.contract = contract
        self.title = title
        self.result = result
    }
    
    fileprivate func confirmTx() {
        let actor = contract.authorization.actor.value
        guard let account = AccountManager.shared.ownerInfos.filter("account = '\(actor)'").first else {
            Log.e("Cannot find valid account info")
            return
        }
        
        guard let usingKey = account.highestPriorityKey else { return }
        
        WaitingView.shared.start()
        
        
        let wallet = Wallet(key: usingKey.eosioKey.key, parent: self)
 
        let isEnabledAutoSign = autoSignEnabled
        
        RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
            .do(onNext: { [weak self] (responseJSON) in
                //TODO: return to callback url
//                Log.i(responseJSON)
                if let txid = responseJSON.string(for: "transaction_id") {
                    //response transacton id
                    self?.result?.onNext(TxResult(txid: txid, autoSign: isEnabledAutoSign))
                }
            }, onError: { [weak self] (error) in
                //TODO: send error to callback
                self?.result?.onError(error)
                Log.i(error)
            })
            .flatMap({ (_) -> Observable<Void> in
                return AccountManager.shared.loadAccounts()
            })
            .subscribe(onError: { (error) in
                guard let error = error as? PrettyPrintedPopup else { return }
                error.showPopup()
            }, onCompleted: { [weak self] in
                Popup.present(style: .success, description: LocalizedString.Tx.success)
                //dismiss
                self?.dismiss()
            }, onDisposed: {
                WaitingView.shared.stop()
            })
            .disposed(by: bag)
    }
    
    fileprivate func changeActor() {
        let alert = UIAlertController(title: LocalizedString.Dapp.Tx.selectAccount, message: LocalizedString.Dapp.Tx.selectAccountTxt, preferredStyle: .actionSheet)
        
        AccountManager.shared.ownerInfos
            .forEach { (info) in
                
                let action = UIAlertAction(title: info.account, style: .default, handler: { [weak self](_) in
                    guard let `self` = self, let key = info.highestPriorityKey else { return }
                    let prvContract = self.contract!
                    self.contract = Contract(code: prvContract.code, action: prvContract.action, args: prvContract.args,
                                             authorization: Authorization(actor: info.account, permission: key.permission))
                    self.tableView.reloadData()
                })
                
                if info.account == self.contract.authorization.actor.value {
                    action.setValue(true, forKey: "checked")
                }
                
                alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: LocalizedString.Common.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    fileprivate func dismiss() {
    
        flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: nil)
    }
    
    fileprivate func cancelled() {
        result?.onError(EOSHubError.userCanceled)
        flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: nil)
    }
}

extension TxConfirmViewController {
    
    enum CellType {
        case action(String)
        case args(key: String, value: String)
        case actor(String)
        case confirm
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = items[indexPath.row]
        switch cellType {
        case .action(let action):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TxConfirmHeaderCell", for: indexPath) as! TxConfirmHeaderCell
            cell.configure(text: action)
            return cell
        case .args(let title, let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TxConfirmArgsCell", for: indexPath) as! TxConfirmArgsCell
            cell.configure(title: title, text: text)
            return cell
        case .actor(let actor):
            let cell = tableView.dequeueReusableCell(withIdentifier: "TxConfirmActorCell", for: indexPath) as! TxConfirmActorCell
            cell.configure(text: actor, observer: autoSignSubject)
            return cell
        case .confirm:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TxConfirmCell", for: indexPath) as! TxConfirmCell
            cell.configure(form: form)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = items[indexPath.row]
        if case CellType.actor = selected {
            changeActor()
        }
    }
}

class TxConfirmHeaderCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbText: UILabel!
    
    func configure(text: String) {
        lbTitle.text = LocalizedString.Dapp.Tx.title
        lbText.text = text
    }
}

class TxConfirmArgsCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbText: UILabel!
    
    func configure(title: String, text: String) {
        lbTitle.text = title
        lbText.text = text
    }
}


class TxConfirmActorCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbText: UILabel!
    @IBOutlet fileprivate weak var lbAutoSign: UILabel!
    @IBOutlet fileprivate weak var swAutoSign: UISwitch!
    
    private var bag: DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    func configure(text: String, observer: PublishSubject<Bool>) {
        lbText.text = text
        lbAutoSign.text = LocalizedString.Tx.autoSign
        
        let bag = DisposeBag()
        self.bag = bag
        swAutoSign.rx.isOn
            .bind { (on) in
                observer.onNext(on)
            }
            .disposed(by: bag)
    }
}

class TxConfirmCell: UITableViewCell {
    @IBOutlet fileprivate weak var btnConfirm: UIButton!
    @IBOutlet fileprivate weak var btnCancel: UIButton!
    
    private var bag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    private func setupUI() {
        btnConfirm.setTitle(LocalizedString.Common.confirmShort, for: .normal)
        btnCancel.setTitle(LocalizedString.Common.cancelShort, for: .normal)
    }
    
    func configure(form: TxConfirmForm) {
        let bag = DisposeBag()
        self.bag = bag
        
        btnConfirm.rx.singleTap
            .bind(to: form.confirm)
            .disposed(by: bag)
        
        btnCancel.rx.tap
            .bind(to: form.cancel)
            .disposed(by: bag)
    }
}

struct TxConfirmForm {
    let confirm = PublishSubject<Void>()
    let cancel = PublishSubject<Void>()
}


