//
//  WalletFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit



class WalletFlowController: FlowController, WalletFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .wallet }
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func show(animated: Bool) {
        var vc: WalletViewController?
        if case FlowType.tab = configure.flowType {
            vc = (configure.container as? TabBarViewController)?.viewControllers.filter({ $0 is WalletViewController }).first as? WalletViewController
        } else {
            vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletViewController") as? WalletViewController
        }
        
        //Test
        let dummyEOSModel = EOSWalletViewModel(account: "eoshubalpha1",
                                               totalEOS: 100000.2423,
                                               estimatedPrice: "102,342,342,424 KRW",
                                               stakedEOS: 23423.02324123,
                                               refundingEOS: 45323,
                                               refundingRemainTime: "2일 23시간 23분",
                                               showSendButton: true)
        
        
//        vc?.configure(data: [dummyEOSModel, WalletAddCellType.add])
        vc?.configure(data: [WalletAddCellType.guide])
        vc?.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    
    //MARK: WalletFlowEventDelegate
    func goToSetting(from nc: UINavigationController) {
        let config = FlowConfigure(container: nc, parent: self, flowType: .navigation)
        let fc = SettingFlowController(configure: config)
        fc.start(animated: true)
    }
    
    func goToWalletDetail(from nc: UINavigationController) {
        
    }
}

protocol WalletFlowEventDelegate: FlowEventDelegate {
    
    func goToSetting(from nc: UINavigationController)
    func goToWalletDetail(from nc: UINavigationController)
}
