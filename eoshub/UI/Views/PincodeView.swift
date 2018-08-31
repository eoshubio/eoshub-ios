//
//  PincodeView.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class PinCodeView: UIView {
    private let maxPinCount = 6
    private var passwordField: UITextField!
    private var containerStack: UIStackView!
    private var dots: [UIView] = []
    private let bag = DisposeBag()
    private var pin: String = ""
    
    var filled = PublishSubject<String>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        bindActions()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        bindActions()
    }
    
    
    private func setupUI() {
        containerStack = UIStackView(frame: bounds)
        containerStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerStack.axis = .horizontal
        containerStack.distribution = .equalSpacing
        addSubview(containerStack)
        addDots()
        
        passwordField = UITextField(frame: .zero)
        passwordField.alpha = 0
//        passwordField.textContentType = .
        passwordField.smartDashesType = .no
        passwordField.smartQuotesType = .no
        passwordField.spellCheckingType = .no
        passwordField.autocorrectionType = .no
        passwordField.smartInsertDeleteType = .no
        passwordField.keyboardType = .numberPad
        passwordField.delegate = self
        
        addSubview(passwordField)
        
        
    }
    
    private func bindActions() {
        passwordField.rx.text.orEmpty
            .subscribe( { [unowned self](text) in
                if let input = text.element {
                    if input.count <= self.maxPinCount && input.count != self.pin.count {
                        self.changePinUI(textCount: input.count)
                        self.pin = input
                        if self.pin.count == self.maxPinCount {
                            let pin = input.subString(startIndex: 0, endIndex: self.maxPinCount-1)
                            self.filled.onNext(pin)
                        }
                    }
                }
            })
            .disposed(by: bag)
    }
    
    private func addDots() {
        for i in 0..<maxPinCount {
            let dot = RoundedView(frame: CGRect(x: 0, y: 0, width: bounds.height, height: bounds.height))
            dot.isUserInteractionEnabled = false
            dot.setCornerRadius(radius: bounds.height * 0.5)
            dot.tag = i
            dot.backgroundColor = Color.seperator.uiColor
            dot.widthAnchor.constraint(equalToConstant: dot.bounds.width).isActive = true
            containerStack.addArrangedSubview(dot)
            dots.append(dot)
        }
    }
    
    private func changePinUI(textCount: Int) {
        for dot in dots {
            if dot.tag < textCount {
                dot.backgroundColor = Color.basePurple.uiColor
            } else {
                dot.backgroundColor = Color.seperator.uiColor
            }
        }
    }
    
    func show() {
        
//        dispatch_async_on_mainThread { [weak self] in
//            self?.passwordField.becomeFirstResponder()
//        }
        
    }
    
    func addInputView(view: UIView) {
        passwordField.inputAccessoryView = view
    }
    
    func clear() {
        passwordField.text = ""
        pin = ""
        changePinUI(textCount: 0)
    }
    
}

extension PinCodeView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = maxPinCount
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
