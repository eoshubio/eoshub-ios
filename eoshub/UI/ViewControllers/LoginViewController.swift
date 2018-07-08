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
    
    @IBOutlet fileprivate weak var containerLoginButtons: UIView!
    
    fileprivate var loginButtons: [UIButton] = []
    
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
        view.backgroundColor = Color.basePurple.uiColor
        //dummy
        let btnLoginWithDummy = UIButton(frame: containerLoginButtons.bounds)
        containerLoginButtons.addSubview(btnLoginWithDummy)
        loginButtons.append(btnLoginWithDummy)
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

