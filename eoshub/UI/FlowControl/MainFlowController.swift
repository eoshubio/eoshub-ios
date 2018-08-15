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
        

//        
//        let account = EHAccount(account: "forthehorde1", publicKey: "PUB_R1_6sCJnLCPf3xrAAaBtq6gikoJNssSu42PDyK3hgDuawP7xsKMcF", owner: true)
        
        _  = Security.shared.setEncryptedKey(pub: "PUB_R1_6sCJnLCPf3xrAAaBtq6gikoJNssSu42PDyK3hgDuawP7xsKMcF", pri: "eoshub.prikey.test.1")
        //        let priKey = "eoshub.prikey.test.1"

//        DB.shared.addAccount(account: account)
//        DB.shared.addOrUpdateObjects([account] as [EHAccount])
        
        let nc = BaseNavigationController()
        
        let frame = UIScreen.main.bounds
        
        nc.view.frame = frame
        
        show(viewController: nc, animated: animated) {
            let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
            
            if self.checkValidLoginToken() {
                let fc = LoginFlowController(configure: config)
                fc.start(animated: false)
                //1. Go To MainTab
                let mainFc = MainTabFlowController(configure: config)
                mainFc.start(animated: false)
            } else {
                //2. Go To Login
                let fc = LoginFlowController(configure: config)
                fc.start(animated: false)
            }
            
            
            

        }
    }
    
    
    private func checkValidLoginToken() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
}
