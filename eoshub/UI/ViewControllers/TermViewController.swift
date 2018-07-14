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
    
    @IBOutlet fileprivate var lbTitle: UILabel!
    @IBOutlet fileprivate var btnPrivacy: UIButton!
    @IBOutlet fileprivate var lbPrivacyDesc: UILabel!
    @IBOutlet fileprivate var btnStart: UIButton!
    
    var flowDelegate: TermFlowEventDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Term.title
        btnPrivacy.setTitle(LocalizedString.Term.goPrivacy, for: .normal)
        btnStart.setTitle(LocalizedString.Term.start, for: .normal)
    }
    
    private func bindActions() {
        btnStart.rx.singleTap
            .bind { [weak self](_) in
                self?.signin()
            }
            .disposed(by: bag)
    }
    
    private func signin() {
        let newUser = EHUser(id: "1", loginType: .kakao)
        DB.shared.addUser(user: newUser)
        
        guard let nc = navigationController else { return }
        flowDelegate?.goToMain(from: nc)
    }
    
    
    
}


//MARK: Layout
extension TermViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
