//
//  FlowController.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit

enum FlowIdentifier: String {
    case main
    case mainTab
    case create
    case createAcc
    case createAccInfo
    case getTxCode
    case importPri
    case importPub
    case findAccount
    case createPin
    case confirmPin
    case validatePin
    case changePin
    case touchID
    case createWallet
    case login
    case term
    case signinEmail
    case forgetPW
    case wallet
    case donate
    case web
    case accountDetail
    case keypair
    case keypairDetail
    case resouces
    case delegatebw
    case undelegatebw
    case buyram
    case sellram
    case send
    case receive
    case qrcode
    case tx
    case vote
    case airdrop
    case ico
    case setting
    case license
    case addToken
    
    case pop
    case dismiss

}

protocol FlowController {
    var id: FlowIdentifier { get }
    var configure: FlowConfigure { get }
    
    init(configure: FlowConfigure)
    func show(animated: Bool)
}

private  var history: [FlowIdentifier] = []

extension FlowController {
    func start(animated: Bool) {
        dispatch_sync_on_mainThread {
            history.append(id)
            show(animated: animated)
        }
    }
    
    func show(viewController vc: UIViewController?, animated: Bool, completion: (() -> Void)?) {
        let flowType = configure.flowType
        let stack = history.map { $0.rawValue }.joined(separator: "-")
        print(stack)
        switch flowType {
        case .window:
            guard let window = configure.container as? UIWindow else {
                preconditionFailure("\(configure.container) is not UIWindow")
            }
            window.rootViewController = vc
            window.makeKeyAndVisible()
            completion?()
        case .modal:
            guard let parent = configure.container as? UIViewController else {
                preconditionFailure("\(configure.container) is not UIViewController")
            }
            parent.present(vc!, animated: animated, completion: completion)
        case .navigation:
            guard let nc = configure.container as? UINavigationController, let vc = vc else {
                preconditionFailure("\(configure.container) is not UINavigationController")
            }
            nc.pushViewController(vc, animated: animated)
            completion?()
        case .navigationInsert:
            guard let nc = configure.container as? UINavigationController, let vc = vc else {
                preconditionFailure("\(configure.container) is not UINavigationController")
            }
            nc.viewControllers = nc.viewControllers + [vc]
            vc.view.alpha = 0
            completion?()
            vc.view.alpha = 1
        case .tab(let idx):
            guard let tc = configure.container as? TabBarViewController else {
                preconditionFailure("\(configure.container) is not TabBarViewController")
            }
            tc.showViewController(at: idx, animated: animated, completion: completion)
        }
    }
}


extension UIViewController {
    
    func closeViewController(animated: Bool, completion: (() -> Void)?) {
        if navigationController == nil {
            if presentingViewController == nil {
                print("first view")
            } else {
                history.append(.dismiss)
                dismiss(animated: animated, completion: completion)
            }
        } else {
            
            if navigationController?.viewControllers.count == 1 {
                //first view 인경우.
                navigationController?.closeViewController(animated: animated, completion: completion)
            } else {
                history.append(.pop)
                navigationController?.popViewController(animated: animated)
                completion?()
            }
        }
    }
}
