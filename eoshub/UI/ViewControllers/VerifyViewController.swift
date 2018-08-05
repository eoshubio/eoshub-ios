//
//  VerifyViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 5..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import FirebaseAuth

class VerifyViewController: BaseViewController {
    
    var flowDelegate: VerifyFlowEventDelegate?
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbDescription: UILabel!
    @IBOutlet fileprivate weak var btnConfirm: UIButton!
    
    fileprivate var email: String!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: Color.basePurple)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    func configure(email: String) {
        self.email = email
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Login.Verify.title
        let text = String(format: LocalizedString.Login.Verify.description, email)
        let desc = NSMutableAttributedString(string: text)
        if let emailRange = text.range(of: email) {
            desc.addAttribute(.foregroundColor, value: Color.lightPurple.uiColor, range: emailRange.nsRange)
        }
        
        lbDescription.attributedText = desc
        
        btnConfirm.setTitle(LocalizedString.Login.Verify.confirm, for: .normal)
    }
    
    private func bindActions() {
        btnConfirm.rx.singleTap
            .bind { [weak self] in
                self?.handleConfirm()
            }
            .disposed(by: bag)
    }
    
    private func handleConfirm() {
        
        let text = String(format: LocalizedString.Login.Verify.reloginText, email)
        let desc = NSMutableAttributedString(string: text)
        if let emailRange = text.range(of: email) {
            desc.addAttribute(.foregroundColor, value: Color.lightPurple.uiColor, range: emailRange.nsRange)
        }
        
        flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: {
            Popup.present(style: .warning, titleString: LocalizedString.Login.Verify.relogin,
                          description: desc)
        })
    }
}
