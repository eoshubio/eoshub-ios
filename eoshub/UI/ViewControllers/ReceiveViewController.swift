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
    @IBOutlet fileprivate weak var btnShare: UIButton!
    @IBOutlet fileprivate weak var lbAccountTitle: UILabel!
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var btnCopyAccount: UIButton!
    @IBOutlet fileprivate weak var lbPubKeyTitle: UILabel!
    @IBOutlet fileprivate weak var lbPubKey: UILabel!
    @IBOutlet fileprivate weak var btnCopyPubKey: UIButton!
    @IBOutlet fileprivate weak var btnHistory: UIButton!
    
    var account: EOSWalletViewModel!
    
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
        
        btnShare.setTitle(LocalizedString.Common.share, for: .normal)
        btnHistory.setTitle(LocalizedString.Wallet.Transfer.history, for: .normal)
        
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
    }
    
    func configure(account: EOSWalletViewModel) {
        self.account = account
    }
    
    
    
}
