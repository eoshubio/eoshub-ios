//
//  MenuTabBar.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


protocol Menu {
    var id: Int { get }
    var title: String { get }
}

enum MainMenu: Int, Menu {
    case wallet, vote, airdrop, ico
    
    var title: String {
        switch self {
        case .wallet:
            return "WALLET"
        case .vote:
            return "VOTE"
        case .airdrop:
            return "Airdrop"
        case .ico:
            return "ICO"
        }
    }
    
    var id: Int {
        return rawValue
    }
}

class MenuTabBar: UIView {
    
    fileprivate var menus: [Menu] = []
    fileprivate var buttons: [UIButton] = []
    fileprivate var stack: UIStackView!
    
    private let bag = DisposeBag()
    
    fileprivate var indicatorView: UIView!
    
    var selectedMenu: Menu?
    let selected = PublishSubject<Menu>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }
    
    private func setupUI() {
        stack = UIStackView(frame: bounds)
        stack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(stack)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .center
        stack.spacing = 0
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        stack.isLayoutMarginsRelativeArrangement = true
        
       
    }
    
    func configure(menus: [Menu]) {
        
        if buttons.count > 0 {
            preconditionFailure("Already initialized")
        }
        
        self.menus = menus
        buttons = menus.map(makeButton)
        buttons.forEach { (btn) in
            stack.addArrangedSubview(btn)
        }
        
        let buttonWidth = stack.bounds.width / CGFloat(stack.arrangedSubviews.count)
        indicatorView = UIView(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: 2))
        indicatorView.backgroundColor = Color.basePurple.uiColor
        indicatorView.isUserInteractionEnabled = false
        addSubview(indicatorView)
        
        
    }
    
    private func makeButton(from menu: Menu) -> UIButton {
        let button = BounceButton(frame: CGRect(x: 0, y: 0, width: 80, height: 50))
        button.setAttributedTitle( NSAttributedString(string: menu.title,
                                                      attributes: [NSAttributedStringKey.font : Font.appleSDGothicNeo(.medium).uiFont(13),
                                                                   NSAttributedStringKey.foregroundColor: Color.gray.uiColor ])
            , for: .normal)
        button.setAttributedTitle( NSAttributedString(string: menu.title,
                                                      attributes: [NSAttributedStringKey.font : Font.appleSDGothicNeo(.bold).uiFont(13),
                                                                   NSAttributedStringKey.foregroundColor: Color.basePurple.uiColor ])
            , for: .selected)
        button.setAttributedTitle( NSAttributedString(string: menu.title,
                                                      attributes: [NSAttributedStringKey.font : Font.appleSDGothicNeo(.regular).uiFont(13),
                                                                   NSAttributedStringKey.foregroundColor: Color.lightGray.uiColor ])
            , for: .disabled)
        
        button.rx.tap
            .bind { [weak self](_) in
                self?.selectMenu(menu: menu)
            }
            .disposed(by: bag)
        
        button.tag = menu.id
        
        return button
    }
    
    fileprivate func selectButton(button: UIButton) {
        buttons.forEach { (btn) in
            if btn == button {
                btn.isSelected = true
                indicatorView.center.x = btn.center.x
            } else {
                btn.isSelected = false
            }
        }
    }
    
    func selectMenu(menu: Menu) {
        if selectedMenu?.id != menu.id {
            selectedMenu = menu
            if let selectedButton = buttons.filter ({ $0.tag == menu.id }).first {
                selectButton(button: selectedButton)
            }
            selected.onNext(menu)
        }
    }
    
}


