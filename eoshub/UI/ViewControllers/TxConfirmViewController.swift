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

class TxConfirmViewController: BaseTableViewController {
    //TODO: login 이 안된 경우 처리.
    //TODO: pin authentication 이 안된 경우 처리.
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: true, largeTitle: true)
        title = "EOSBet.io"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindActions()
    }
    
    private func bindActions() {
        
        form.confirm
            .bind(onNext: confirmTx)
            .disposed(by: bag)
        
        form.cancel
            .bind(onNext: dismiss)
            .disposed(by: bag)
        
    }
    //TODO: contract 가 아니고 scheme 을 받아와야함. 그래야 wildcard 를 선택한 계정으로 대체 할 수 있음.
    func configure(contract: Contract) {
        self.contract = contract
    }
    
    fileprivate func confirmTx() {
        let actor = contract.authorization.actor.value
        guard let account = AccountManager.shared.ownerInfos.filter("account = '\(actor)'").first else {
            Log.e("Cannot find valid account info")
            return
        }
        
        
        WaitingView.shared.start()
        
        let wallet = Wallet(key: account.pubKey, parent: self)
 
        RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
            .do(onNext: { (responseJSON) in
                //TODO: return to callback url
                Log.i(responseJSON)
            }, onError: { (error) in
                //TODO: send error to callback
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
        let alert = UIAlertController(title: LocalizedString.Vote.changeAccount, message: "트랜젝션을 승인할 EOS 계정을 선택해 주세요.", preferredStyle: .actionSheet)
        
        AccountManager.shared.ownerInfos
            .forEach { (info) in
                
                let action = UIAlertAction(title: info.account, style: .default, handler: { [weak self](_) in
                    guard let `self` = self else { return }
                    let prvContract = self.contract!
                    self.contract = Contract(code: prvContract.code, action: prvContract.action, args: prvContract.args,
                                             authorization: Authorization(actor: info.account, permission: info.permission))
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
        navigationController?.popViewController(animated: true)
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
            cell.configure(text: actor)
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
    
    func configure(text: String) {
        lbText.text = text
    }
}

class TxConfirmCell: UITableViewCell {
    @IBOutlet fileprivate weak var btnConfirm: UIButton!
    @IBOutlet fileprivate weak var btnCancel: UIButton!
    
    private var bag: DisposeBag?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
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


