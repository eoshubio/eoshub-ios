//
//  VoteFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class VoteFlowController: FlowController, VoteFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .vote }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    fileprivate var account: AccountInfo!
    
    func configure(account: AccountInfo) {
        self.account = account
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: VoteViewController.self)
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoteViewController") as? VoteViewController else { return }
        vc.flowDelegate = self
        vc.configure(account: account)
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func goToWalletDetail(from nc: UINavigationController, account: AccountInfo) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = WalletDetailFlowController(configure: config)
        fc.configure(account: account)
        fc.start(animated: true)
    }
}

protocol VoteFlowEventDelegate: FlowEventDelegate {
    func goToWalletDetail(from nc: UINavigationController, account: AccountInfo)
}

