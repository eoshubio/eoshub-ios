//
//  CustomPopup.swift
//  eoshub
//
//  Created by kein on 06/05/2019.
//  Copyright © 2019 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift

class CustomPopup: UIView {
    
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var lbTitle: UILabel?
    @IBOutlet weak var btnAction: UIButton?
    @IBOutlet weak var btnCancel: UIButton?
    @IBOutlet weak var layoutCenterY: NSLayoutConstraint?
    
    var actionSubject = PublishSubject<Void>()
    
    let bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        bindAction()
    }
    
    func setupUI() {
        self.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        let notifier = NotificationCenter.default
        notifier.addObserver(self,
                             selector: #selector(keyboardWillShowNotification(_:)),
                             name: UIWindow.keyboardWillShowNotification,
                             object: nil)
        notifier.addObserver(self,
                             selector: #selector(keyboardWillHideNotification(_:)),
                             name: UIWindow.keyboardWillHideNotification,
                             object: nil)
    }
        
    @objc
    func keyboardWillShowNotification(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let remainHeight = bounds.height - keyboardHeight
            let diffY = remainHeight - popup.frame.maxY - 5
            if diffY < 0 {
                layoutCenterY?.constant = diffY
                setNeedsLayout()
            }
        }
    }
        
    @objc
    func keyboardWillHideNotification(_ notification: NSNotification) {
        layoutCenterY?.constant = 0
        setNeedsLayout()
    }
    
    private func bindAction() {
        btnAction?.rx.singleTap
            .bind { [weak self] in
                self?.actionSubject.onNext(())
                self?.close()
        }
        .disposed(by: bag)
        
        btnCancel?.rx.singleTap
            .bind { [weak self] in
                self?.close()
        }
        .disposed(by: bag)
    }
    
    private func close() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.alpha = 0
            self?.popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { [weak self](_) in
            self?.removeFromSuperview()
        }
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!
        frame = UIScreen.main.bounds
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.popup.transform = .identity
        }
    }
    
}
