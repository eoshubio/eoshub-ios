//
//  BaseTableViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 13..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BaseTableViewController: UITableViewController {
    
    let bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showNavigationBar(with tintColor: Color, animated: Bool = true, largeTitle: Bool = false) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        //        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.view.backgroundColor = UIColor.clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = tintColor.uiColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: tintColor.uiColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: tintColor.uiColor]
        
        navigationController?.navigationBar.prefersLargeTitles = largeTitle
        switch tintColor {
        case .white:
            navigationController?.navigationBar.barStyle = .black
        case .basePurple, .darkGray:
            navigationController?.navigationBar.barStyle = .default
        default:
            break
        }
        
        
        
    }
    
}
