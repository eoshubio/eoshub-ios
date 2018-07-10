//
//  ImportViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class ImportViewController: TextInputViewController {
    
    var flowDelegate: ImportFlowEventDelegate?
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var txtAccount: UITextField!
    @IBOutlet fileprivate weak var txtPriKey: UITextField!
    @IBOutlet fileprivate weak var btnPaste: UIButton!
    @IBOutlet fileprivate weak var btnImport: UIButton!
    @IBOutlet fileprivate weak var btnFindAccount: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .darkGray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Wallet.Import.title
        btnPaste.setTitle(LocalizedString.Common.paste, for: .normal)
        btnImport.setTitle(LocalizedString.Wallet.Import.store, for: .normal)
        
        let txt = LocalizedString.Wallet.Import.findAccount
        let txtFindAccount = NSMutableAttributedString(string: txt,
        attributes: [NSAttributedStringKey.font: Font.appleSDGothicNeo(.regular).uiFont(12),
                     NSAttributedStringKey.foregroundColor: Color.darkGray.uiColor])
        
        if let clickRange = txt.range(of: LocalizedString.Wallet.Import.clickHere) {
            let clickNSRange = txt.nsRange(from: clickRange)
            txtFindAccount.addAttributes([NSAttributedStringKey.font : Font.appleSDGothicNeo(.bold).uiFont(12),
                                          NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue],
                                         range: clickNSRange)
        }
        
        
        btnFindAccount.setAttributedTitle(txtFindAccount, for: .normal)
        
        
        txtAccount.placeholder = LocalizedString.Wallet.Import.account
        txtPriKey.placeholder = LocalizedString.Wallet.priKey
        txtAccount.delegate = self
        txtPriKey.delegate = self
  
        
    }
    
    private func bindActions() {
        btnFindAccount.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goFindAccount(from: nc)
            }
        .disposed(by: bag)
    }
    
}
