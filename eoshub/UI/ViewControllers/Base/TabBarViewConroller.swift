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
            viewControllers.forEach { contentView.addSubview($0.view) }
        }
    }

    var contentView: UIView = UIView()
    
    @IBOutlet var menuContainer: UIView!
    
    weak var menuTabBar: MenuTabBar!
    
    var currentMenu: Menu?
    
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
        contentView.frame.origin.x = CGFloat(viewControllers.count) * view.bounds.width
        contentView.frame.size.width = view.bounds.width
        contentView.frame.size.height = view.bounds.height - view.safeAreaInsets.bottom - view.safeAreaInsets.top
        
        for i in 0..<viewControllers.count {
            let v = viewControllers[i].view!
            v.frame = CGRect(x: CGFloat(i) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        }
        
        let idx = currentMenu?.id ?? 0
        
        showViewController(at: idx, animated: false, completion: nil)
    }
    
    func showViewController(at idx: Int, animated: Bool, completion: (()->Void)?) {
        let centerX = view.bounds.width * (0.5 - CGFloat(idx))
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.contentView.center.x = centerX
            }) { (_) in
                completion?()
            }
        } else {
            contentView.center.x = centerX
        }
        
    }
    
}
