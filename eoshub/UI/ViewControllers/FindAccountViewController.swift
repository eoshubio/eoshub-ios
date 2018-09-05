//
//  FindAccountViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class FindAccountViewController: TextInputViewController {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var txtPubKey: UITextField!
    @IBOutlet fileprivate weak var txtAccount: UITextField!
    @IBOutlet fileprivate weak var viewAccount: UIView!
    @IBOutlet fileprivate weak var layoutAccountHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var btnCopy: UIButton!
    @IBOutlet fileprivate weak var btnPaste: UIButton!
    @IBOutlet fileprivate weak var btnFind: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: Color.darkGray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Wallet.Find.title
        btnCopy.setTitle(LocalizedString.Common.copy, for: .normal)
        btnPaste.setTitle(LocalizedString.Common.paste, for: .normal)
        btnFind.setTitle(LocalizedString.Wallet.Find.search, for: .normal)
        
        txtPubKey.placeholder = LocalizedString.Wallet.pubKey
        txtPubKey.delegate = self
        
        txtAccount.placeholder = nil
        txtAccount.isEnabled = false
        
        viewAccount.isHidden = true
        layoutAccountHeight.constant = 1
        
        view.layoutIfNeeded()
    }
    
    private func bindActions() {
        btnFind.rx.singleTap
            .bind { [weak self] in
                self?.viewAccount.isHidden = false
                self?.layoutAccountHeight.constant = 44
                self?.view.layoutIfNeeded()
            }
            .disposed(by: bag)
    }
    
}
