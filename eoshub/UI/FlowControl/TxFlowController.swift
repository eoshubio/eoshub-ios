//
//  TxFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TxFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .tx }
    
    fileprivate var accountName: String!
    fileprivate var actions: [String]?
    fileprivate var filter: Symbol?
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(accountName: String, actions: [String]?, filter: Symbol?) {
        self.accountName = accountName
        self.actions = actions
        self.filter = filter
    }

    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: TxViewController.self)
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "TxViewController") as? TxViewController else { return }
        
        vc.configure(account: accountName, actions: actions, filter: filter)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
}



