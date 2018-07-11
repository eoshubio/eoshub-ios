//
//  MainTabBarFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class MainTabFlowController: FlowController, MainTabFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .mainTab }
    
    var subFlows: [FlowIdentifier] = [.wallet, .vote, .airdrop]
    
//    var subFlows: [FlowIdentifier] = [.vote]
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyBoard.instantiateViewController(withIdentifier: "MainTabViewController") as? MainTabViewController else { preconditionFailure() }
        vc.flowDelegate = self
        
        vc.viewControllers = subFlows.compactMap { (flow) -> UIViewController? in
            switch flow {
            case .wallet:
                let vc = storyBoard.instantiateViewController(withIdentifier: "WalletViewController")
                return vc
            case .vote:
                let vc = storyBoard.instantiateViewController(withIdentifier: "VoteViewController")
                return vc
            case .airdrop:
                let vc = storyBoard.instantiateViewController(withIdentifier: "AirdropViewController")
                return vc
            default:
                return nil
            }
        }
        
        show(viewController: vc, animated: animated) { [unowned self] in
            self.go(from: vc, to: .wallet, animated: false)
        }
        
        
    }
     
    
    //MARK: MainTabFlowEventDelegate
    func go(from tc: TabBarViewController, to tab: MainMenu, animated: Bool) {
        let config = FlowConfigure(container: tc, parent: self, flowType: .tab(tab.id))
        switch tab {
        case .wallet:
            let fc = WalletFlowController(configure: config)
            fc.start(animated: animated)
        case .vote:
            let fc = VoteFlowController(configure: config)
            fc.start(animated: animated)
        case .airdrop:
            let fc = AirdropFlowController(configure: config)
            fc.start(animated: animated)
        default:
            break
        }
    }
    
    func cratePin(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .modal)
        let fc = CreatePinFlowController(configure: config)
        fc.start(animated: true)
    }
}

protocol MainTabFlowEventDelegate: FlowEventDelegate {
    
    func go(from tc: TabBarViewController, to tab: MainMenu, animated: Bool)
    func cratePin(from nc: UINavigationController)
}
