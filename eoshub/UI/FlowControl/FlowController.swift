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
    case createWallet
    case login
    case term
    case wallet
    case setting
    
    case pop
    case dismiss
}

protocol FlowController {
    var id: FlowIdentifier { get }
    var configure: FlowConfigure { get }
    
    init(configure: FlowConfigure)
    func show(animated: Bool)
    
    func start(animated: Bool) //Do not implement
}

private  var history: [FlowIdentifier] = []

extension FlowController {
    func start(animated: Bool) {
        dispatch_sync_on_mainThread {
            history.append(id)
            show(animated: animated)
        }
    }
    
    func show(viewController vc: UIViewController, animated: Bool, completion: (() -> Void)?) {
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
            guard let vc = configure.container as? UIViewController else {
                preconditionFailure("\(configure.container) is not UIViewController")
            }
            vc.present(vc, animated: animated, completion: completion)
        case .navigation:
            guard let nc = configure.container as? UINavigationController else {
                preconditionFailure("\(configure.container) is not UINavigationController")
            }
            nc.pushViewController(vc, animated: animated)
            completion?()
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

