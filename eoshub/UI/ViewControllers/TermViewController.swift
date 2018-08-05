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
    @IBOutlet fileprivate var lbPrivacyDesc: UITextView!
    @IBOutlet fileprivate var btnStart: UIButton!
    
    var flowDelegate: TermFlowEventDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Term.title
        btnPrivacy.setTitle(LocalizedString.Term.termAndPrivacy, for: .normal)
        btnStart.setTitle(LocalizedString.Term.start, for: .normal)
        let termPolicyText = LocalizedString.Term.privacyDesc
        let termPolicyString = NSMutableAttributedString(string: termPolicyText)
        if let termRange = termPolicyText.range(of: LocalizedString.Term.term), let policyRange = termPolicyText.range(of: LocalizedString.Term.goPrivacy) {
            let langCode = Locale.current.languageCode ?? "en"
            termPolicyString.addAttribute(NSAttributedStringKey.link, value: EOSHubAPI.URL.term.getHtml(languateCode: langCode), range: termRange.nsRange)
            termPolicyString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.blue.uiColor, range: termRange.nsRange)
            termPolicyString.addAttribute(NSAttributedStringKey.link, value: EOSHubAPI.URL.privacy_policy.getHtml(languateCode: langCode), range: policyRange.nsRange)
            termPolicyString.addAttribute(NSAttributedStringKey.foregroundColor, value: Color.blue.uiColor, range: policyRange.nsRange)

        }
        
        lbPrivacyDesc.attributedText = termPolicyString
        lbPrivacyDesc.isUserInteractionEnabled = true
        
    }
    
    private func bindActions() {
        btnStart.rx.singleTap
            .bind { [weak self](_) in
                self?.signin()
            }
            .disposed(by: bag)
    }
    
    private func signin() {
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
