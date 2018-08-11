//
//  CreateAccountInvoiceViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 11..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class CreateAccountInvoiceViewController: BaseTableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refresh))
        
        title = LocalizedString.Create.Account.title + " (3/3)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc fileprivate func refresh() {
        
    }
}

extension CreateAccountInvoiceViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountInvoiceCell", for: indexPath) as? CreateAccountInvoiceCell else { preconditionFailure() }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateAccountRequestCell", for: indexPath) as? CreateAccountRequestCell else { preconditionFailure() }
            return cell
        default:
            preconditionFailure()
        }
    }
}


class CreateAccountInvoiceCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var timerCount: BorderColorButton!
    @IBOutlet fileprivate weak var lbTextDeposit: UILabel!
    @IBOutlet fileprivate weak var lbTextTimeLimit: UILabel!
    @IBOutlet fileprivate weak var lbNameTitle: UILabel!
    @IBOutlet fileprivate weak var lbName: UILabel!
    @IBOutlet fileprivate weak var btnCopyAccount: UIButton!
    @IBOutlet fileprivate weak var lbMemoTitle: UILabel!
    @IBOutlet fileprivate weak var lbMemo: UILabel!
    @IBOutlet fileprivate weak var btnCopyMemo: UIButton!
    @IBOutlet fileprivate weak var lbQuantityCPU: UILabel!
    @IBOutlet fileprivate weak var lbQuantityNet: UILabel!
    @IBOutlet fileprivate weak var lbQuantityRAM: UILabel!
    @IBOutlet fileprivate weak var lbQuantityTotal: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupUI() {
        
        lbTitle.text = LocalizedString.Create.Invoice.title
        lbTextDeposit.text = LocalizedString.Create.Invoice.textDeposit
        
        lbNameTitle.text = LocalizedString.Create.Check.name
        lbMemoTitle.text = LocalizedString.Create.Invoice.memo
        
        let timeLimit = String(format: LocalizedString.Create.Invoice.timelimit, "\(1)")
        let txtTimeLimit = String(format: LocalizedString.Create.Invoice.textTimelimit, timeLimit)
        let attrTimeLimit = NSMutableAttributedString(string: txtTimeLimit)
        attrTimeLimit.addAttributeColor(text: timeLimit, color: Color.red.uiColor)
        lbTextTimeLimit.attributedText = attrTimeLimit
        
        btnCopyMemo.setTitle(LocalizedString.Common.copy, for: .normal)
        btnCopyAccount.setTitle(LocalizedString.Common.copy, for: .normal)
        
        timerCount.setThemeColor(fgColor: Color.red.uiColor, bgColor: .clear, state: .normal)
    }
    
    private func bindActions() {
        _ = btnCopyAccount.rx.tap
            .bind { [weak self] in
                guard let account = self?.lbName.text else { return }
                UIPasteboard.general.string = account
            }
        
        _ = btnCopyMemo.rx.tap
            .bind { [weak self] in
                guard let memo = self?.lbMemo.text else { return }
                UIPasteboard.general.string = memo
        }
    }
    
    
    
    
    
}



class CreateAccountRequestCell: UITableViewCell {
    @IBOutlet fileprivate weak var lbTextConfirm: UILabel!
    @IBOutlet fileprivate weak var btnConfirm: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupUI() {
        lbTextConfirm.text = LocalizedString.Create.Invoice.textConfirm
        btnConfirm.setTitle(LocalizedString.Create.Invoice.confirm, for: .normal)
    }
    
    
}




