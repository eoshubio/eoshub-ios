//
//  TabBarViewConroller.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: BaseViewController {
    var viewControllers: [UIViewController] = [] {
        didSet {
            contentView.subviews.forEach { $0.removeFromSuperview() }
            childViewControllers.forEach { $0.removeFromParentViewController()}
            viewControllers.forEach { vc in
                addChildViewController(vc)
                contentView.addSubview(vc.view)
            }
        }
    }

    var contentView: UIView = UIView()
    
    @IBOutlet var menuContainer: UIView!
    
    weak var menuTabBar: MenuTabBar!
    
    var currentMenuIdx: Int = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        contentView.autoresizingMask = [.flexibleHeight]
        view.insertSubview(contentView, at: 0)
        
        let menus = MenuTabBar(frame: CGRect(x: 0, y: 0, width: menuContainer.bounds.width, height: 50))
        menus.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        menuContainer.addSubview(menus)
        
        menuTabBar = menus
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        relayoutSubViewControllers()
    }
    
    fileprivate func relayoutSubViewControllers() {
        contentView.frame.origin.y = view.safeAreaInsets.top
//        contentView.frame.origin.x = 0
        contentView.frame.size.width = view.bounds.width * CGFloat(viewControllers.count)
        contentView.frame.size.height = view.bounds.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top - menuTabBar.bounds.height
        
        for i in 0..<viewControllers.count {
            let v = viewControllers[i].view!
            v.frame = CGRect(x: CGFloat(i) * view.bounds.width, y: 0, width: view.bounds.width, height: contentView.bounds.height)
        }
        
        let idx = currentMenuIdx
        
        showViewController(at: idx, animated: false, completion: nil)
    }
    
    func showViewController(at idx: Int, animated: Bool, completion: (()->Void)?) {
        currentMenuIdx = idx
        let x = view.bounds.width * CGFloat(idx)
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.contentView.frame.origin.x = -x
            }) { (_) in
                completion?()
            }
        } else {
            contentView.frame.origin.x = -x
        }
        
    }
    
}
