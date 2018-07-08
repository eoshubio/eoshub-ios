//
//  FlowEventDelegate.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 18..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import UIKit



protocol FlowEventDelegate: class {
    func finish(viewControllerToFinish: UIViewController, animated: Bool, completion: (()->Void)?)
}

extension FlowEventDelegate {
    func finish(viewControllerToFinish: UIViewController, animated: Bool, completion: (()->Void)?) {
        viewControllerToFinish.closeViewController(animated: animated, completion: completion)
    }
    
    
    //모든 View 를 날리는 경우.
    func goToRoot(viewControllerToFinish: UIViewController, animated: Bool, completion: (()->Void)?) {
        
        if viewControllerToFinish.navigationController == nil {
            if viewControllerToFinish.presentingViewController == nil {
//                Flow.addFlow(id: .root)
                viewControllerToFinish.dismiss(animated: animated, completion: completion)
            } else {
                goToRoot(viewControllerToFinish: viewControllerToFinish.presentingViewController!, animated: animated, completion: completion)
            }
        } else {
//            Flow.addFlow(id: .root)
            viewControllerToFinish.navigationController?.popToRootViewController(animated: animated)
            completion?()
        }
    }
}


