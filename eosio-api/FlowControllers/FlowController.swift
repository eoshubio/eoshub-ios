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
    case wallet
    case setting
}

protocol FlowController {
    var id: FlowIdentifier { get }
    var configure: FlowConfigure { get }
    
    init(configure: FlowConfigure)
    func show()
    
    func start() //Do not implement
}

private  var history: [FlowIdentifier] = []

extension FlowController {
    func start() {
        dispatch_sync_on_mainThread {
            history.append(id)
            show()
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



