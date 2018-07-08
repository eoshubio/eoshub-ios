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

class LoginViewController: BaseViewController {
    
    var flowDelegate: LoginFlowEventDelegate?
    @IBOutlet fileprivate weak var lbTitle: UILabel!
//    @IBOutlet fileprivate weak var containerLoginButtons: UIView!
    
    @IBOutlet fileprivate weak var stackLoginButtons: UIStackView!
    
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
        
        //TODO: Check that the app is installed.
        var availableLoginTypes: [LoginType] = [.facebook, .google]
        
        if Locale.current.regionCode == "KR" {
            availableLoginTypes = [.facebook, .kakao, .google]
        }
        
        stackLoginButtons.spacing = 10
        
        
        availableLoginTypes.forEach { (type) in
            let loginButton = LoginButton(frame: CGRect(x: 0, y: 0, width: stackLoginButtons.bounds.width, height: 44))
            loginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            loginButton.configure(type: type)
            stackLoginButtons.addArrangedSubview(loginButton)
            loginButtons.append(loginButton)
        }
        
        //dummy
//        let btnLoginWithDummy = LoginButton(frame: CGRect(x: 0, y: 0, width: containerLoginButtons.bounds.width, height: 44))
//        containerLoginButtons.addSubview(btnLoginWithDummy)
//        loginButtons.append(btnLoginWithDummy)
    }
    
    private func bindActions() {
        loginButtons.forEach { (button) in
            button.rx.singleTap
                .bind(onNext: { [weak self](_) in
                    guard let nc = self?.navigationController else { return }
                    self?.flowDelegate?.goToTerm(from: nc)
                })
                .disposed(by: bag)
        }
    }
    
    
}

