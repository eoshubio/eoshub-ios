//
//  KeypairDetailFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 9. 15..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class KeypairDetailFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .keypairDetail }
    
    fileprivate var account: AccountInfo!
    fileprivate var permission: Permission!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(account: AccountInfo, permission: Permission) {
        self.account = account
        self.permission = permission
    }
    
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: KeypairDetailViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "KeypairDetailViewController") as? KeypairDetailViewController else { return }
        vc.configure(account: account, permission: permission)
        show(viewController: vc, animated: animated) {
            
        }
    }
}



