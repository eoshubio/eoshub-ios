//
//  TextInputViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit


class TextInputViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var contentsScrollView: UIScrollView!
    
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
      
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
}

extension TextInputViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        activeField?.resignFirstResponder()
        activeField = nil
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        var inset = contentsScrollView.contentInset
        inset.bottom = keyboardSize.height - view.safeAreaInsets.bottom
        contentsScrollView.contentInset = inset
        
        guard let currentField = activeField else { return }
        let absoluteFrame = currentField.convert(currentField.frame, to: view)
        if absoluteFrame.maxY > (view.bounds.height - keyboardSize.height) {
            contentsScrollView.contentOffset.y = keyboardSize.height
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        contentsScrollView.contentInset = .zero
    }
}
