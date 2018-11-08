//
//  DappWebFlowController.swift
//  eoshub
//
//  Created by kein on 26/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class DappWebFlowController: FlowController, DappWebFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .dappWeb }
    
    var dappAction: DappAction!
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(dappAction: DappAction) {
        self.dappAction = dappAction
    }
    
    func show(animated: Bool) {
        EHAnalytics.trackScreen(name: id.rawValue, classOfFlow: DappWebViewController.self)
        
        var vc: DappWebViewController
        
        if configure.container is DappWebViewController {
            vc = configure.container as! DappWebViewController
            vc.configure(dappAction: dappAction)
            vc.reloadDappWeb()
        } else {
            guard let dappVC = UIStoryboard(name: "Dapp", bundle: nil).instantiateViewController(withIdentifier: "DappWebViewController") as? DappWebViewController else { return }
            vc = dappVC
            vc.flowDelegate = self
            let nc = UINavigationController(rootViewController: vc)
            vc.configure(dappAction: dappAction)
            show(viewController: nc, animated: animated) {
                
            }
        }
    }
    
    func goToTxConfirm(vc: UIViewController, contract: Contract, title: String?, result: PublishSubject<TxResult>?) {
        let config = FlowConfigure(container: vc, parent: self, flowType: .modal)
        let fc = TxConfirmFlowController(configure: config)
        fc.configure(contract: contract, title: title, result: result)
        fc.start(animated: true)
    }
}

protocol DappWebFlowEventDelegate: FlowEventDelegate {
    
    func goToTxConfirm(vc: UIViewController, contract: Contract, title: String?, result: PublishSubject<TxResult>?)
    
}
