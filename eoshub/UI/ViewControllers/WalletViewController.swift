//
//  WalletViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WalletViewController: BaseViewController {
    
    var flowDelegate: WalletFlowEventDelegate?
    
    @IBOutlet fileprivate var btnNotice: UIButton!
    @IBOutlet fileprivate var btnSetting: UIButton!
    @IBOutlet fileprivate var btnProfile: RoundedButton!
    
    @IBOutlet fileprivate var walletList: UICollectionView!
    
    @IBOutlet fileprivate var botContainer: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
  
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        
    }
    
    private func setupUI() {
        btnProfile.setCornerRadius(radius: btnProfile.bounds.height * 0.5)
        btnProfile.imageView?.contentMode = .scaleAspectFill
        btnProfile.layer.shadowColor = UIColor.black.cgColor
        btnProfile.layer.shadowOffset = .zero
        btnProfile.layer.shadowRadius = 1.0
        
    }
    
   
    private func bindActions() {
        btnSetting.rx.singleTap
            .bind { [weak self](_) in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToSetting(from: nc)
            }
            .disposed(by: bag)
    }
}
