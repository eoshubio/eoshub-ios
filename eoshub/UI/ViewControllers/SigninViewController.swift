//
//  SigninViewController.swift
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

class SigninViewController: TextInputViewController {
    
    var flowDelegate: SigninEmailFlowEventDelegate?
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var txtEmail: UITextField!
    @IBOutlet fileprivate weak var txtPasswd: UITextField!
    @IBOutlet fileprivate weak var btnSignin: UIButton!
    @IBOutlet fileprivate weak var btnResetPW: UIButton!
    
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
        lbTitle.text = LocalizedString.Login.email
        txtEmail.placeholder = LocalizedString.Login.Email.email
        txtPasswd.placeholder = LocalizedString.Login.Email.pw
        
        let forGotText = NSAttributedString(string: LocalizedString.Login.Email.forgot,
                                            attributes: [NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue])
        
        btnResetPW.setAttributedTitle(forGotText, for: .normal)
        
        btnSignin.setTitle(LocalizedString.Login.Email.signin, for: .normal)
    }
    
    private func bindActions() {
        btnSignin.isEnabled = false
        
        let emailCheck = txtEmail.rx.text.orEmpty.flatMap(isValidEmail())
        let pwCheck = txtPasswd.rx.text.orEmpty.flatMap(isStrongPassword(minCount: 6))
        
        Observable.combineLatest([emailCheck, pwCheck])
            .flatMap(isValid())
            .bind(to: rx_isEnabled)
            .disposed(by: bag)

        rx_isEnabled
            .bind(to: btnSignin.rx.isEnabled)
            .disposed(by: bag)
        
        btnResetPW.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToForgotPW(from: nc)
            }
            .disposed(by: bag)
        
        btnSignin.rx.singleTap
            .bind { [weak self] in
                self?.handleSignin()
            }
            .disposed(by: bag)
        
    }
    
    private func isStrongPassword(minCount: Int) -> (String) -> Observable<Bool> {
        return { pw in
            return Observable.just(pw.count >= minCount)
        }
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
    
    private func isValid() -> ([Bool]) -> Observable<Bool> {
        return { checklist in
            for valid in checklist {
                if valid == false {
                    return Observable.just(false)
                }
            }
            
            return Observable.just(true)
        }
    }
    
    private func handleSignin() {
        
        view.endEditing(true)
        
        guard let email = txtEmail.text?.trimmingCharacters(in: .whitespaces), let password = txtPasswd.text else { return }
        WaitingView.shared.start()
        Auth.auth().signIn(withEmail: email, password: password) { [weak self](user, error) in
            if let error = error {
                if let authErrorType = AuthError.getError(error: error)?.type, authErrorType == AuthErrorType.ERROR_USER_NOT_FOUND {
                    //create
                    self?.createUserWithEmail(email: email, password: password)
                } else {
                    self?.failToLogin(error: error)
                }
                return
            } else if let user = user {
                if user.user.isEmailVerified {
                    self?.loggedIn(user: user)
                } else {
                    self?.verifyEmail(user: user.user, email: email)
                }
            }
        }
    }
    
    
    
    private func createUserWithEmail(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self](user, error) in
            
            if let error = error {
                Log.e(error)
                self?.failToLogin(error: error)
                return
            } else if let user = user {
                if user.user.isEmailVerified {
                    self?.loggedIn(user: user)
                } else {
                    self?.verifyEmail(user: user.user, email: email)
                }
            }
        }
    }
    
    private func verifyEmail(user: User, email: String) {
        
        let actionCodeSettings =  ActionCodeSettings()
        
        user.sendEmailVerification(with: actionCodeSettings) { [weak self] (error) in
            
            if let error = error {
                self?.failToLogin(error: error)
            } else {
                
                let text = String(format: LocalizedString.Login.Email.verify, email)
                let description = NSMutableAttributedString(string: text)
                if let emailRange = text.range(of: email) {
                    description.addAttribute(.foregroundColor, value: Color.lightPurple.uiColor, range: emailRange.nsRange)
                }
                
                Popup.present(style: .success, description: description)
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.goToVerifyEmail(from: nc, email: email)
                WaitingView.shared.stop()
            }
        }
        
    }
    
    private func loggedIn(user: AuthDataResult) {
        WaitingView.shared.stop()
        
        guard let nc = self.navigationController else { return }
        
        if user.additionalUserInfo?.isNewUser == true {
            //sign-up
            flowDelegate?.goToTerm(from: nc)
        } else {
            //log-in
            flowDelegate?.goToMain(from: nc)
        }
        
    }
    
    private func failToLogin(error: Error?) {
        WaitingView.shared.stop()
        if let error = error {
            AuthError(with: error as NSError).showPopup()
        }
    }
    
}
