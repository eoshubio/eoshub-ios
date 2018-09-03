//
//  LoginViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth

class LoginViewController: AuthViewController {
    
    var flowDelegate: LoginFlowEventDelegate?
    @IBOutlet fileprivate weak var lbTitle: UILabel!
//    @IBOutlet fileprivate weak var containerLoginButtons: UIView!
    
    @IBOutlet fileprivate weak var stackLoginButtons: UIStackView!
    
    @IBOutlet fileprivate weak var btnSkipLogin: UIButton?
    
    fileprivate var loginButtons: [LoginButton] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        bindActions()
    }
    
    //MARK: setup
    private func setupUI() {
        lbTitle.text = LocalizedString.Intro.title
        
        if getDisplaySize() == .size_3_5 {
            lbTitle.isHidden = true
        }
        
        let availableLoginTypes: [LoginType] = [.facebook, .google, .email]
        
        stackLoginButtons.spacing = 10
        let white = UIColor(white: 1.0, alpha: 0.8)
        let anonymouseTitle = NSAttributedString(string: LocalizedString.Login.none,
                                                 attributes: [NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue,
                                                              NSAttributedStringKey.foregroundColor: white])
        btnSkipLogin?.setAttributedTitle(anonymouseTitle, for: .normal)
        
        availableLoginTypes.forEach { (type) in
            let loginButton = LoginButton(frame: CGRect(x: 0, y: 0, width: stackLoginButtons.bounds.width, height: 44))
            loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            loginButton.configure(type: type)
            stackLoginButtons.addArrangedSubview(loginButton)
            loginButtons.append(loginButton)
        }
    }
    
    private func bindActions() {
        loginButtons.forEach { (button) in
            button.rx.singleTap
                .bind(onNext: { [weak self](_) in
                    self?.login(with: button.type)
                    
                })
                .disposed(by: bag)
        }
        
        btnSkipLogin?.rx.singleTap
            .bind { [weak self] in
                self?.login(with: .none)
            }
            .disposed(by: bag)
    }

    
    override func login(with type: LoginType) {
        
        switch type {
        case .email:
            guard let nc = navigationController else { return }
            flowDelegate?.goToSignin(from: nc)
        default:
            super.login(with: type)
        }
        
//        WaitingView.shared.start()
    }
    
    override func loggedIn(user: AuthDataResult) {
//        WaitingView.shared.stop()
        
        DB.shared = DB()
        
        guard let nc = self.navigationController else { return }
        if user.additionalUserInfo?.isNewUser == true {
            //sign-up
            flowDelegate?.goToTerm(from: nc)
        } else {
            //log-in
            flowDelegate?.goToMain(from: nc)
        }
        
    }
    
    override func failToLogin(error: Error?) {
        if let error = error {
            Log.e(error)
            AuthError(with: error as NSError).showPopup()
        }
    }
    
}

