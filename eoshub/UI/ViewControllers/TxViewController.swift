//
//  TxViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RealmSwift

class TxViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate lazy var items: Results<Tx> = {
        var result = TxManager.shared.getTx(for: account)
        
        if let filter = filter {
            result =  result.filter("data CONTAINS ' \(filter)\"'")
        }
        
        if let actions = actions?.map({$0.rawValue}) {
            result = result.filter("action IN %@", actions)
        }

        return result
    }()
    
    fileprivate var account: String!
    fileprivate var actions: [Contract.Action]?
    fileprivate var filter: Symbol?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = LocalizedString.Tx.title
        showNavigationBar(with: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    func configure(account: String, actions: [Contract.Action]?, filter: Symbol?) {
        self.account = account
        self.actions = actions
        self.filter = filter
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    private func bindActions() {
        TxManager.shared.loadTx(for: account)
            .subscribe(onNext: { [weak self] (_) in
                self?.tableView.reloadData()
                }, onError: { (error) in
                    Log.e(error)
            })
            .disposed(by: bag)
    }
    
}

extension TxViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TxCell", for: indexPath) as? TxCell else { preconditionFailure() }
        let item = items[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(myaccount: account, tx: item)
        return cell
    }
    
}


class TxCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbInOut: UILabel!
    @IBOutlet fileprivate weak var lbRelatedAccount: UILabel!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    @IBOutlet fileprivate weak var lbTxDate: UILabel!
    @IBOutlet fileprivate weak var lbTxIdTitle: UILabel!
    @IBOutlet fileprivate weak var btnTxId: UIButton!
    @IBOutlet fileprivate weak var lbMemoTitle: UILabel!
    @IBOutlet fileprivate weak var lbMemo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        lbTxIdTitle.text = LocalizedString.Tx.id
        lbMemoTitle.text = LocalizedString.Wallet.Transfer.memo
        btnTxId.titleLabel?.numberOfLines = 2
        btnTxId.titleLabel?.textAlignment = .right
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lbInOut.text = nil
        lbRelatedAccount.text = nil
        lbQuantity.text = nil
        lbSymbol.text = nil
        lbTxDate.text = nil
        lbMemoTitle.text = nil
        lbMemo.text = nil
        btnTxId.setAttributedTitle(nil, for: .normal)
        
    }
    
    func configure(myaccount: String, tx: Tx) {
        lbTxDate.text = Date(timeIntervalSince1970: tx.timeStamp).dataToLocalTime()
        setTxId(id: tx.txid)
        
        switch tx.action {
        case Contract.Action.transfer.rawValue:
            fillTansferData(with: tx.data, myaccount: myaccount)
        case Contract.Action.buyram.rawValue:
            fillBuyRamData(with: tx.data, myaccount: myaccount)
        case Contract.Action.sellram.rawValue:
            fillSellRamData(with: tx.data, myaccount: myaccount)
        case Contract.Action.delegatebw.rawValue:
            fillDelegateBWData(with: tx.data, myaccount: myaccount)
        case Contract.Action.undelegatebw.rawValue:
            fillUndelegateBWData(with: tx.data, myaccount: myaccount)
        default:
            break
        }
    }
    
    private func fillTansferData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        guard let from = data.string(for: Contract.Args.transfer.from),
            let to = data.string(for: Contract.Args.transfer.to),
            let currencyString = data.string(for: Contract.Args.transfer.quantity),
            let currency = Currency(currency: currencyString),
            let memo = data.string(for: Contract.Args.transfer.memo) else { return }

        let outBound: Bool = from == myaccount
        if outBound {
            lbInOut.text = LocalizedString.Tx.sended
            lbInOut.textColor = Color.blue.uiColor
            lbRelatedAccount.text = "(\(to))"
        } else {
            lbInOut.text = LocalizedString.Tx.received
            lbInOut.textColor = Color.red.uiColor
            lbRelatedAccount.text = "(\(from))"
        }
        
        lbQuantity.text = currency.balance
        lbSymbol.text = currency.symbol
        
        lbMemo.isHidden = (memo.count == 0)
        lbMemoTitle.isHidden = (memo.count == 0)
        lbMemo.text = memo
    }
    
    private func fillBuyRamData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        lbInOut.text = LocalizedString.Wallet.Ram.buy
        lbInOut.textColor = Color.blue.uiColor
        lbRelatedAccount.text = ""

        if let quant = data.string(for: Contract.Args.buyram.quant), let currency = Currency(currency: quant) {
            lbQuantity.text = currency.balance
            lbSymbol.text = currency.symbol
        }
        
        lbMemo.isHidden = true
        lbMemoTitle.isHidden = true
    }
    
    private func fillSellRamData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        lbInOut.text = LocalizedString.Wallet.Ram.sell
        lbInOut.textColor = Color.red.uiColor
        lbRelatedAccount.text = ""
        
        if let bytes = data.integer64(for: Contract.Args.sellram.bytes) {
            lbQuantity.text = bytes.prettyPrinted
            lbSymbol.text = "RAM"
        }
        
        lbMemo.isHidden = true
        lbMemoTitle.isHidden = true
    }
    
    private func fillDelegateBWData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        lbInOut.text = LocalizedString.Wallet.Delegate.delegateTitle
        lbInOut.textColor = Color.blue.uiColor
        lbRelatedAccount.text = ""
        
        if let cpuQu = data.string(for: Contract.Args.delegatebw.stake_cpu_quantity),
            let netQu = data.string(for: Contract.Args.delegatebw.stake_net_quantity) {
            
            lbMemoTitle.isHidden = false
            lbMemo.isHidden = false
            
            lbMemoTitle.text = LocalizedString.Wallet.Transfer.quantity
            lbMemo.text = "CPU: " + cpuQu + " / Network: " + netQu
        }
        
        lbQuantity.text = ""
        lbSymbol.text = ""
        
    }
    
    private func fillUndelegateBWData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        lbInOut.text = LocalizedString.Wallet.Delegate.undelegate
        lbInOut.textColor = Color.red.uiColor
        lbRelatedAccount.text = ""
        
        if let cpuQu = data.string(for: Contract.Args.undelegatebw.unstake_cpu_quantity),
            let netQu = data.string(for: Contract.Args.undelegatebw.unstake_net_quantity){
            
            lbMemoTitle.isHidden = false
            lbMemo.isHidden = false
            
            lbMemoTitle.text = LocalizedString.Wallet.Transfer.quantity
            lbMemo.text = "CPU: " + cpuQu + " / Network: " + netQu
        }
        
        lbQuantity.text = ""
        lbSymbol.text = ""
    }
    
    private func setTxId(id: String) {
        let txId = NSAttributedString(string: id, attributes: [NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue])
        btnTxId.setAttributedTitle(txId, for: .normal)
    }
    
}
