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

class TxViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var items: [Tx] = []
    fileprivate var account: AccountInfo!
    fileprivate var filter: [Symbol] = []
    
    
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
    
    func configure(account: AccountInfo, filter: [Symbol]) {
        self.account = account
        self.filter = filter
    }
    
    private func setupUI() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
    }
    
    private func bindActions() {
        RxEOSAPI.getTxHistory(account: account.account)
            .subscribe(onNext: { [weak self] (txs) in
                self?.updateTx(txs: txs)
                self?.tableView.reloadData()
                }, onError: { (error) in
                    Log.e(error)
            })
            .disposed(by: bag)
    }
    
    private func updateTx(txs: [Tx]) {
        items.removeAll()
        if filter.count > 0 {
            items = txs.filter({ filter.contains($0.symbol) })
                .sorted(by: { (lhs, rhs) -> Bool in
                    return lhs.timeStamp > rhs.timeStamp
                })
        } else {
            items = txs.sorted(by: { (lhs, rhs) -> Bool in
                        return lhs.timeStamp > rhs.timeStamp
                    })
        }
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
        cell.configure(myaccount: account.account, tx: item)
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
        let outBound: Bool = tx.from == myaccount
        if outBound {
            lbInOut.text = LocalizedString.Tx.sended
            lbInOut.textColor = Color.blue.uiColor
            lbRelatedAccount.text = "(\(tx.to))"
        } else {
            lbInOut.text = LocalizedString.Tx.received
            lbInOut.textColor = Color.red.uiColor
            lbRelatedAccount.text = "(\(tx.from))"
        }
        
        lbQuantity.text = tx.quantity.balance
        lbSymbol.text = tx.quantity.symbol
        lbTxDate.text = Date(timeIntervalSince1970: tx.timeStamp).dataToLocalTime()
        
        setTxId(id: tx.id)
        
        lbMemo.isHidden = (tx.memo.count == 0)
        lbMemoTitle.isHidden = (tx.memo.count == 0)
        lbMemo.text = tx.memo
        
    }
    
    private func setTxId(id: String) {
        let txId = NSAttributedString(string: id, attributes: [NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue])
        btnTxId.setAttributedTitle(txId, for: .normal)
    }
    
}
