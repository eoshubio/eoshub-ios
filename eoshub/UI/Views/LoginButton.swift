//
//  LoginButton.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit



class LoginButton: RoundedButton {
    
    private let nibName: String = "LoginButton"
    
    @IBOutlet fileprivate var _view: UIView!
    @IBOutlet fileprivate var icon: UIImageView!
    @IBOutlet fileprivate var titleView: UILabel!
    
    var type: LoginType!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        let bundle = Bundle.main
        bundle.loadNibNamed(nibName, owner: self, options: nil)
        _view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(_view)
    }
    
    func configure(type: LoginType) {
        self.type = type
        icon.image = type.icon
        titleView.text = type.title.capitalized
        titleView.textColor = type.textColor
        _view.backgroundColor = type.bgColor
        
    }
    
}

extension LoginType {
    var icon: UIImage? {
        switch self {
        case .facebook:
            return UIImage(named: "facebook")
        case .google:
            return UIImage(named: "google")
        case .kakao:
            return UIImage(named: "kakaotalk")
        case .email:
            return nil
        case .none:
            return nil
        }
    }
    
    var bgColor: UIColor {
        switch self {
        case .facebook:
            return UIColor.colorUInt8(r: 41, g: 134, b: 255)
        case .google:
            return UIColor.colorUInt8(r: 255, g: 95, b: 84)
        case .kakao:
            return UIColor.colorUInt8(r: 255, g: 155, b: 0)
        case .email:
            return UIColor.colorUInt8(r: 255, g: 95, b: 84)
        case .none:
            return UIColor.clear
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .facebook:
            return UIColor.white
        case .google:
            return UIColor.white
        case .kakao:
            return UIColor.white
        case .email:
            return UIColor.white
        case .none:
            return UIColor.white
        }
    }
}
