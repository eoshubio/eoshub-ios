//
//  ImportViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class ImportViewController: BaseViewController {
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var txtAccount: UITextField!
    @IBOutlet fileprivate weak var txtPriKey: UITextField!
    @IBOutlet fileprivate weak var btnPaste: UIButton!
    @IBOutlet fileprivate weak var btnImport: UIButton!
    @IBOutlet fileprivate weak var btnFindAccount: UIButton!
    
    @IBOutlet fileprivate weak var contentsScrollView: UIScrollView!
    
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Wallet.Import.title
        txtAccount.placeholder = LocalizedString.Wallet.Import.account
        txtPriKey.placeholder = LocalizedString.Wallet.Import.priKey
        btnPaste.setTitle(LocalizedString.Common.paste, for: .normal)
        btnImport.setTitle(LocalizedString.Wallet.Import.store, for: .normal)
        
        let txt = LocalizedString.Wallet.Import.findAccount
        let txtFindAccount = NSMutableAttributedString(string: txt,
        attributes: [NSAttributedStringKey.font: Font.appleSDGothicNeo(.regular).uiFont(12),
                     NSAttributedStringKey.foregroundColor: Color.darkGray.uiColor])
        
        if let clickRange = txt.range(of: LocalizedString.Wallet.Import.clickHere) {
            let clickNSRange = txt.nsRange(from: clickRange)
            txtFindAccount.addAttributes([NSAttributedStringKey.font : Font.appleSDGothicNeo(.bold).uiFont(12),
                                          NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue],
                                         range: clickNSRange)
        }
        
        
        btnFindAccount.setAttributedTitle(txtFindAccount, for: .normal)
        
        
        
        
        
        txtAccount.delegate = self
        txtPriKey.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
}

extension ImportViewController: UITextFieldDelegate {
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
