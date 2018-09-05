//
//  MainTabViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class MainTabViewController: TabBarViewController, MenuTabBarDeleagte {
  
    var flowDelegate: MainTabFlowEventDelegate?
    
    let accountMgr = AccountManager.shared
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if Security.shared.needAuthentication {
            view.isUserInteractionEnabled = false
            checkPin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        setupMenus()
        menuContainer.layer.shadowOpacity = 0.2
        menuContainer.layer.shadowRadius = 4
        menuContainer.layer.shadowOffset = CGSize(width: 0, height: -1)
        menuContainer.layer.shadowColor = UIColor.black.cgColor
    }
    
    private func bindActions() {
        menuTabBar.selected
            .bind { [weak self](menu) in
                guard let menu = menu as? MainMenu else { return }
                self?.go(to: menu)
            }
            .disposed(by: bag)
        
        Security.shared.authorized
            .subscribe(onNext:{ [weak self](isAuthorized) in
                if isAuthorized {
                    //show wallet
                } else {
                    //lock wallet
                }
                self?.view.isUserInteractionEnabled = true
            })
            .disposed(by: bag)
    }
    
    private func setupMenus() {
        menuTabBar.configure(menus: [MainMenu.wallet, MainMenu.vote, MainMenu.airdrop])
        menuTabBar.delegate = self
        menuTabBar.selectMenu(menu: MainMenu.wallet)
    }
    
    private func checkPin() {
        guard let nc = navigationController else { return }
        if self.isCreatedPin() == false {
           flowDelegate?.cratePin(from: nc)
        } else {
           flowDelegate?.validatePin(from: nc)
        }
    }
    
    private func isCreatedPin() -> Bool {
        return Security.shared.hasPin()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    private func go(to menu: MainMenu) {
        flowDelegate?.go(from: self, to: menu, animated: true)
    }
    
    func canMoveToMenu(menu: Menu) -> Bool {
        switch menu {
        case MainMenu.vote:
            let hasOwnerMode = AccountManager.shared.infos.filter("ownerMode = true").count > 0
            return hasOwnerMode
        default:
            return true
        }
    }
}
