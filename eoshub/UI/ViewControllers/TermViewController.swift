//
//  TermViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class TermViewController: BaseViewController {
    @IBOutlet fileprivate var btnStart: UIButton!
    @IBOutlet fileprivate var btnPrivacy: UIButton!
    @IBOutlet fileprivate var lbPrivacyDesc: UILabel!
    
    var flowDelegate: TermFlowEventDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
    }
    
    private func bindActions() {
        btnStart.rx.singleTap
            .bind { [weak self](_) in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToWallet(from: nc)
            }
            .disposed(by: bag)
    }
}


//MARK: Layout
extension TermViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
