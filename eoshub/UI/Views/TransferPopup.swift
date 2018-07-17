//
//  TransferPopup.swift
//  eoshub
//
//  Created by kein on 2018. 7. 17..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class TransferPopup: UIView {
    
    @IBOutlet fileprivate weak var container: UIView!
    @IBOutlet fileprivate weak var bgView: UIView!
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbSendTo: UILabel!
    @IBOutlet fileprivate weak var lbAccount: UILabel!
    @IBOutlet fileprivate weak var lbMemoTitle: UILabel!
    @IBOutlet fileprivate weak var lbMemo: UILabel!
    @IBOutlet fileprivate weak var lbQuantityTitle: UILabel!
    @IBOutlet fileprivate weak var lbQuantity: UILabel!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    @IBOutlet fileprivate weak var btnApply: UIButton!
    @IBOutlet fileprivate weak var btnCancel: UIButton!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Wallet.Transfer.popupTitle
        lbSendTo.text = LocalizedString.Wallet.Transfer.sendTo
        lbMemoTitle.text = LocalizedString.Wallet.Transfer.memo
        lbQuantityTitle.text = LocalizedString.Wallet.Transfer.quantity
        btnApply.setTitle(LocalizedString.Wallet.Transfer.transfer, for: .normal)
        btnCancel.setTitle(LocalizedString.Common.cancel, for: .normal)
    }
    
    deinit {
        Log.d("deinit")
        bag = nil
    }
    
    func configure(account: String, memo: String, quantity: Double, symbol: String, observer: AnyObserver<Bool>) {
        
        let bag = DisposeBag()
        
        lbAccount.text = account
        lbMemo.text = memo
        lbQuantity.text = quantity.dot4String
        lbSymbol.text = symbol
        
        btnApply.rx.singleTap
            .bind { [weak self] in
                observer.onNext(true)
                observer.onCompleted()
                self?.dismiss()
            }
            .disposed(by: bag)
        
        btnCancel.rx.singleTap
            .bind { [weak self] in
                observer.onNext(false)
                observer.onCompleted()
                self?.dismiss()
            }
            .disposed(by: bag)
        
        
        self.bag = bag
    }
    
    private func dismiss() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.container.alpha = 0
            self.bgView.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    fileprivate func presentAnimation() {
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        bgView.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.container.alpha = 1
            self.container.transform = CGAffineTransform.identity
            self.bgView.alpha = 0.8
        })
        
    }
    
    
    static func show(account: String, memo: String, quantity: Double, symbol: String) -> Observable<Bool> {
        
        return Observable<Bool>.create({ (observer) -> Disposable in
            
            guard let popup = Bundle.main.loadNibNamed("TransferPopup", owner: nil, options: nil)?.first as? TransferPopup else {
                preconditionFailure("TransferPopup View did not load")
            }
            
            
            
            let window = UIApplication.shared.keyWindow!
            popup.frame = window.bounds
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(popup)
            
            popup.configure(account: account, memo: memo, quantity: quantity, symbol: symbol, observer: observer)
            
            popup.presentAnimation()
            
            return Disposables.create {
                
            }
        })
        
    }
}
