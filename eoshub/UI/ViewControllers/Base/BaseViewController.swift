//
//  BaseViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    var bag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showNavigationBar(with tintColor: Color, bgColor: Color = .baseGray, animated: Bool = true, largeTitle: Bool = false) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        
        
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.isTranslucent = true

        navigationController?.navigationBar.tintColor = tintColor.uiColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: tintColor.uiColor]
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedStringKey.foregroundColor: tintColor.uiColor,
             NSAttributedStringKey.font: Font.appleSDGothicNeo(.bold).uiFont(30)]

        navigationController?.navigationBar.prefersLargeTitles = largeTitle
        
        
        switch tintColor {
        case .white:
            navigationController?.navigationBar.setBackgroundImage(UIImage() , for: UIBarMetrics.default)
            navigationController?.navigationBar.backgroundColor = .clear
            navigationController?.navigationBar.barStyle = .black
        case .basePurple, .darkGray:
            let bgTranslucent = bgColor.getUIColor(alpha: 0.8)
            navigationController?.navigationBar.setBackgroundImage(UIImage(color: bgTranslucent) , for: UIBarMetrics.default)
            navigationController?.navigationBar.backgroundColor = .clear
            navigationController?.navigationBar.barStyle = .default
        default:
            break
        }
    }
    
    func addBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.back))
        
        
    }
    
}


extension BaseViewController {
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
}
