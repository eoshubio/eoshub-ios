//
//  ForgetViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 5..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Firebase
import FirebaseAuth

class ForgotPWViewController: TextInputViewController {
    
    var flowDelegate: FlowEventDelegate?
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var txtEmail: UITextField!
    @IBOutlet fileprivate weak var btnReset: UIButton!
    
    let rx_isEnabled = BehaviorSubject<Bool>(value: false)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: Color.basePurple)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Login.ForgotPW.title
        txtEmail.placeholder = LocalizedString.Login.Email.email
        btnReset.setTitle(LocalizedString.Login.ForgotPW.send, for: .normal)
    }
    
    private func bindActions() {
        btnReset.isEnabled = false
        
        let emailCheck = txtEmail.rx.text.orEmpty.flatMap(isValidEmail())
        
        emailCheck
            .bind(to: rx_isEnabled)
            .disposed(by: bag)
        
        rx_isEnabled
            .bind(to: btnReset.rx.isEnabled)
            .disposed(by: bag)
        
        btnReset.rx.singleTap
            .bind { [weak self] in
                self?.sendResetPassword()
            }
            .disposed(by: bag)
        
    }
    
    private func isValidEmail() -> (String) -> Observable<Bool> {
        return { email in
            let inputEmail = email.trimmingCharacters(in: .whitespaces)
            let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
            let valid = emailPredicate.evaluate(with: inputEmail)
            return Observable.just(valid)
        }
        
    }

    private func sendResetPassword() {
        WaitingView.shared.start()
        txtEmail.resignFirstResponder()
        
        guard let email = txtEmail.text?.trimmingCharacters(in: .whitespaces) else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] (error) in
            WaitingView.shared.stop()
            if let error = error {
                Log.e(error)
                AuthError(with: error as NSError).showPopup()
            } else {
                
                let text = String(format: LocalizedString.Login.Email.verify, email)
                let description = NSMutableAttributedString(string: text)
                if let emailRange = text.range(of: email) {
                    description.addAttribute(.foregroundColor, value: Color.lightPurple.uiColor, range: emailRange.nsRange)
                }
                Popup.present(style: .success, description: description)
                guard let `self` = self else { return }
                self.flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: nil)
            }
        }

    }
    
    
}
