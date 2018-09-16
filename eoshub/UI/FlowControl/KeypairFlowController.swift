//
//  KeypairFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class KeypairFlowController: FlowController, KeypairFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .keypair }
    
    var account: AccountInfo!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: KeypairViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "KeypairViewController") as? KeypairViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToDetail(from nc: UINavigationController, permission: Permission) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = KeypairDetailFlowController(configure: config)
        fc.configure(account: account, permission: permission)
        fc.start(animated: true)
    }
}


protocol KeypairFlowEventDelegate: FlowEventDelegate {
    func goToDetail(from nc: UINavigationController, permission: Permission)
}
