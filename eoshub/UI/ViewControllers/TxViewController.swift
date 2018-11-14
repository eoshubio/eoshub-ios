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

class TxViewController: BaseTableViewController {
    fileprivate var account: String!
    fileprivate var actions: [String]?
    fileprivate var filter: Symbol?
    fileprivate var items: [Tx] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        title = LocalizedString.Tx.title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    func configure(account: String, actions: [String]?, filter: Symbol?) {
        self.account = account
        self.actions = actions
        self.filter = filter
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    private func bindActions() {
        
        //show on local
        updateDataSource()
        
        TxManager.shared.loadTx(for: account)
            .subscribe(onNext: { [weak self] (_) in
                self?.updateDataSource()
                self?.tableView.reloadData()
                }, onError: { (error) in
                    if let e = error as? PrettyPrintedPopup {
                        e.showPopup()
                    } else {
                        Log.e(error)
                    }
            }) {
                
            }
            .disposed(by: bag)
    }
    
    private func updateDataSource() {
        var result = TxManager.shared.getTx(for: account)
    
        if let filter = filter {
            result =  result.filter("data CONTAINS ' \(filter)\"'")
        }
    
        if let actions = actions {
            result = result.filter("action IN %@", actions)
        }
    
        items = Array(result)
    }
    
}

extension TxViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TxCell", for: indexPath) as? TxCell else { preconditionFailure() }
        let item = items[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(myaccount: account, tx: item)
        return cell
    }
    
}


class TxCell: UITableViewCell {
//    @IBOutlet fileprivate weak var lbInOut: UILabel!
    @IBOutlet fileprivate weak var btnAction: UIButton!
    @IBOutlet fileprivate weak var lbRelatedAccount: UILabel!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    @IBOutlet fileprivate weak var lbTxDate: UILabel!
//    @IBOutlet fileprivate weak var lbTxIdTitle: UILabel!
    @IBOutlet fileprivate weak var btnTxId: UIButton!
//    @IBOutlet fileprivate weak var lbMemoTitle: UILabel!
    @IBOutlet fileprivate weak var lbMemo: UILabel!
    
    fileprivate var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
//        lbTxIdTitle.text = LocalizedString.Tx.id
//        lbMemoTitle.text = LocalizedString.Wallet.Transfer.memo
//        btnTxId.titleLabel?.numberOfLines = 2
//        btnTxId.titleLabel?.textAlignment = .right
        btnAction.isUserInteractionEnabled = false
        btnAction.layer.cornerRadius = 3
        btnAction.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
        lbRelatedAccount.text = nil
        lbQuantity.text = nil
        lbSymbol.text = nil
        lbTxDate.text = nil
//        lbMemoTitle.text = nil
//        lbMemo.text = nil
//        lbMemo.attributedText = nil
        btnTxId.setAttributedTitle(nil, for: .normal)
        
    }
    
    func configure(myaccount: String, tx: Tx) {
        let bag = DisposeBag()
        self.bag = bag
        lbTxDate.text = Date(timeIntervalSince1970: tx.timeStamp).dataToLocalTime()
        setTxId(id: tx.txid)
        
        btnTxId.rx.singleTap
            .bind {
                if let url = URL(string: Config.txHost + tx.txid), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            .disposed(by: bag)
        
        switch tx.action {
        case Contract.Action.transfer:
            fillTansferData(with: tx.data, myaccount: myaccount, contract: tx.contract)
        case Contract.Action.buyram:
            fillBuyRamData(with: tx.data, myaccount: myaccount)
        case Contract.Action.sellram:
            fillSellRamData(with: tx.data, myaccount: myaccount)
        case Contract.Action.delegatebw:
            fillDelegateBWData(with: tx.data, myaccount: myaccount)
        case Contract.Action.undelegatebw:
            fillUndelegateBWData(with: tx.data, myaccount: myaccount)
        default:
            fillCustomData(with: tx, myaccount: myaccount)
        }
        
    }
    
    private func fillTansferData(with dataString: String, myaccount: String, contract: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        guard let from = data.string(for: Contract.Args.transfer.from),
            let to = data.string(for: Contract.Args.transfer.to),
            let currencyString = data.string(for: Contract.Args.transfer.quantity),
            let currency = Currency.create(stringValue: currencyString, contract: contract),
            let memo = data.string(for: Contract.Args.transfer.memo) else { return }

        let outBound: Bool = from == myaccount
        if outBound {
            btnAction.setTitle("Sent", for: .normal)
            btnAction.backgroundColor = Color.blue.uiColor
            lbRelatedAccount.text = "(\(to))"
        } else {
            btnAction.setTitle("Received", for: .normal)
            btnAction.backgroundColor = Color.red.uiColor
            lbRelatedAccount.text = "(\(from))"
        }
        
        lbQuantity.text = currency.balance
        lbSymbol.text = currency.symbol

        lbMemo.text = memo
    }
    
    private func fillBuyRamData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
    
        btnAction.setTitle("Buy RAM", for: .normal)
        btnAction.backgroundColor = Color.blue.uiColor
        lbRelatedAccount.text = ""

        if let quant = data.string(for: Contract.Args.buyram.quant), let currency = Currency(eosCurrency: quant) {
            lbQuantity.text = currency.balance
            lbSymbol.text = currency.symbol
        }

    }
    
    private func fillSellRamData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        btnAction.setTitle("Sell RAM", for: .normal)
        btnAction.backgroundColor = Color.red.uiColor
        lbRelatedAccount.text = ""
        
        if let bytes = data.integer64(for: Contract.Args.sellram.bytes) {
            lbQuantity.text = bytes.prettyPrinted
            lbSymbol.text = "RAM"
        }

    }
    
    private func fillDelegateBWData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        btnAction.setTitle("Delegate Bandwidth", for: .normal)
        btnAction.backgroundColor = Color.blue.uiColor
        lbRelatedAccount.text = ""
        
        if let cpuQu = data.string(for: Contract.Args.delegatebw.stake_cpu_quantity),
            let netQu = data.string(for: Contract.Args.delegatebw.stake_net_quantity) {

            lbMemo.text = "CPU: " + cpuQu + " / Network: " + netQu
        }
        
        lbQuantity.text = ""
        lbSymbol.text = ""
        
    }
    
    private func fillUndelegateBWData(with dataString: String, myaccount: String) {
        
        guard let data = JSON.createJSON(from: dataString) else { return }
        
        btnAction.setTitle("Undelegate Bandwidth", for: .normal)
        btnAction.backgroundColor = Color.red.uiColor
        lbRelatedAccount.text = ""
        
        if let cpuQu = data.string(for: Contract.Args.undelegatebw.unstake_cpu_quantity),
            let netQu = data.string(for: Contract.Args.undelegatebw.unstake_net_quantity){

            lbMemo.text = "CPU: " + cpuQu + " / Network: " + netQu
        }
        
        lbQuantity.text = ""
        lbSymbol.text = ""
    }
    
    private func fillCustomData(with tx: Tx, myaccount: String) {
        btnAction.setTitle( tx.action, for: .normal)
        if tx.contract == "eosio" || tx.action == "receipt" {
            btnAction.backgroundColor = Color.progressOrange.uiColor
        } else {
            btnAction.backgroundColor = Color.gray.uiColor
        }
        
        lbRelatedAccount.text = "(\(tx.contract))"
        
        if let json = JSON.createJSON(from: tx.data) {
            let highlightedJSON = JSONSyntaxHighlight(json: json)
            highlightedJSON?.keyAttributes = [NSAttributedString.Key.foregroundColor: Color.red.uiColor,
                                              NSAttributedString.Key.font: Font.appleSDGothicNeo(.medium).uiFont(13)]
            highlightedJSON?.stringAttributes = [NSAttributedString.Key.foregroundColor: Color.darkGray.uiColor]
            highlightedJSON?.nonStringAttributes = [NSAttributedString.Key.foregroundColor: Color.progressOrange.uiColor]
            
            let attrText = highlightedJSON?.highlightJSON()
            
            lbMemo.attributedText = attrText
        } else {
            lbMemo.text = tx.data
        }
    }
    
    private func setTxId(id: String) {
        let txId = NSAttributedString(string: String(id[0..<6]), attributes:
            [NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue,
             NSAttributedString.Key.foregroundColor: Color.blue.uiColor])
        btnTxId.setAttributedTitle(txId, for: .normal)
        
    }
    
}
