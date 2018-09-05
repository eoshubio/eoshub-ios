//
//  BaseNavigationController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let popVC = super.popViewController(animated: animated)
        Log.d(String(describing: popVC))
        
        if let topVC = viewControllers.last as? NavigationPopDelegate {
            topVC.setNavigationBarAtributes()
        }
        
        return popVC
    }
    
    private func resetNavigationBarSetting(for viewController: BaseViewController) {
        
    }

}

protocol NavigationPopDelegate {
    func setNavigationBarAtributes()
}
