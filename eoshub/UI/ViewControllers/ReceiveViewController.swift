//
//  ReceiveViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 12..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import QRCode

class ReceiveViewController: BaseViewController {
    
    var flowDelegate: ReceiveEventDelegate?
    
    @IBOutlet fileprivate weak var qrcode: UIImageView!
    @IBOutlet fileprivate weak var btnShareContainer: UIView!
    @IBOutlet fileprivate weak var lbShare: UILabel!
    @IBOutlet fileprivate weak var btnShare: UIButton!
    @IBOutlet fileprivate weak var lbAccountTitle: UILabel!
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var btnCopyAccount: UIButton!
    @IBOutlet fileprivate weak var lbPubKeyTitle: UILabel!
    @IBOutlet fileprivate weak var lbPubKey: UILabel!
    @IBOutlet fileprivate weak var btnCopyPubKey: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    var account: AccountInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = LocalizedString.Wallet.receive
        showNavigationBar(with: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindAction()
    }
    
    private func setupUI() {
        lbAccountTitle.text = LocalizedString.Wallet.Transfer.account
        lbAccount.text = account.account
        lbPubKeyTitle.text = LocalizedString.Wallet.pubKey
        lbPubKey.text = account.pubKey
        lbShare.text = LocalizedString.Common.share
        
        btnHistory.setTitle(LocalizedString.Wallet.Transfer.history, for: .normal)
        
        btnCopyAccount.setTitle(LocalizedString.Common.copy, for: .normal)
        btnCopyPubKey.setTitle(LocalizedString.Common.copy, for: .normal)
        
        btnShareContainer.layer.borderColor = Color.white.cgColor
        btnShareContainer.layer.borderWidth = 1
        
        
        qrcode.layer.shadowColor = UIColor.black.cgColor
        qrcode.layer.shadowOffset = CGSize(width: 1, height: 1)
        qrcode.layer.shadowRadius = 3
        
        
        
        var qr = QRCode(account.pubKey)
        qr?.size = qrcode.bounds.size
        let qrImage = qr?.image
        qrcode.image = qrImage
        
        
        
    }
    
    private func bindAction() {
        btnHistory.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToTx(from: nc)
            }
            .disposed(by: bag)
        
        
        btnCopyAccount.rx.tap
            .bind { [weak self] in
                guard let text = self?.account.account else { return }
                UIPasteboard.general.string = text
            }
            .disposed(by: bag)
        
        btnCopyPubKey.rx.tap
            .bind { [weak self] in
                guard let text = self?.account.pubKey else { return }
                UIPasteboard.general.string = text
            }
            .disposed(by: bag)
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    
}
