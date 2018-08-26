//
//  MainFlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class MainFlowController: FlowController {
    var configure: FlowConfigure

    var id: FlowIdentifier { return .main }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        //TODO: Load App configs
        TokenManager.shared.load()
        
        if isJailBroken() {
            
            Popup.present(style: .failed, description: "Jailbroken device is not supported.")
            
            return
        }
      
        let nc = BaseNavigationController()
        
        let frame = UIScreen.main.bounds
        
        nc.view.frame = frame
        
        show(viewController: nc, animated: animated) {
            
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)

            if self.checkValidLoginToken() {
                let fc = LoginFlowController(configure: config)
                fc.start(animated: false)
                //1. Go To MainTab
                let mainFc = WalletFlowController(configure: config)
                mainFc.start(animated: false)
            } else {
                //2. Go To Login
                let fc = LoginFlowController(configure: config)
                fc.start(animated: false)
            }
            
            
            

        }
    }
    
    
    private func checkValidLoginToken() -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        if  user.loginType == .email {
            return user.isEmailVerified
        } else {
            return true
        }
    }
    
    private func isJailBroken() -> Bool {
        var jailBroken = false
        let cydiaPath = "/Applications/Cydia.app"
        let aptPath = "/private/var/lib/apt/"
        if FileManager.default.fileExists(atPath: cydiaPath) {
            jailBroken = true
        }
        if FileManager.default.fileExists(atPath: aptPath) {
            jailBroken = true
        }
        return jailBroken
    }
    
}
