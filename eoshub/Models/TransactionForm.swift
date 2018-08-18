//
//  TransactionForm.swift
//  eoshub
//
//  Created by kein on 2018. 7. 22..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol TransactionForm {
    var transaction: PublishSubject<Void> { get }
}

class TransactionInputFormCell: UITableViewCell {
    
    func makeTransactionButtonToKeyboard(title: String, form: TransactionForm, bag: DisposeBag, available: Observable<Bool>) -> UIView {
        let toolbar = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 64))
        let btnTx = ActionButton(frame: CGRect(x: 0, y: 0, width: toolbar.bounds.width - 30, height: 44))
        btnTx.setCornerRadius(radius: 3)
        btnTx.setTitle(title, for: .normal)
        btnTx.titleLabel?.font = Font.appleSDGothicNeo(.bold).uiFont(15)
        toolbar.addSubview(btnTx)
        btnTx.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            btnTx.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor, constant: 15),
            btnTx.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor, constant: -15),
            btnTx.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor),
            btnTx.heightAnchor.constraint(equalToConstant: 44)
            ])
        
        available
            .bind(to: btnTx.rx.isEnabled)
            .disposed(by: bag)
        
        btnTx.rx.singleTap
            .bind { [weak self] in
                form.transaction.onNext(())
                self?.endEditing(true)
            }
            .disposed(by: bag)
        
        return toolbar
    }
}
