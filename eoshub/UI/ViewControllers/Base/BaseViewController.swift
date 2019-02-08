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
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor.uiColor]
        navigationController?.navigationBar.largeTitleTextAttributes =
            [NSAttributedString.Key.foregroundColor: tintColor.uiColor,
             NSAttributedString.Key.font: Font.appleSDGothicNeo(.bold).uiFont(30)]

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
        navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizedString.Common.back, style: .plain, target: self, action: #selector(self.back))
    }
    
    func addCloseButton() {
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.setImage(UIImage(named: "close"), for: .normal)
        button.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        
        let closeItem = UIBarButtonItem(customView: button)
        closeItem.customView?.widthAnchor.constraint(equalToConstant: 26).isActive = true
        closeItem.customView?.heightAnchor.constraint(equalToConstant: 26).isActive = true
        navigationItem.rightBarButtonItem = closeItem
    }
}


extension BaseViewController {
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
