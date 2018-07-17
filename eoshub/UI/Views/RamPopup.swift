//
//  RamPopup.swift
//  eoshub
//
//  Created by kein on 2018. 7. 17..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class RamPopup: UIView {
    
    @IBOutlet fileprivate weak var container: UIView!
    @IBOutlet fileprivate weak var bgView: UIView!
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    
    @IBOutlet fileprivate weak var lbBytesTitle: UILabel!
    @IBOutlet fileprivate weak var lbBytes: UILabel!
    @IBOutlet fileprivate weak var lbByteSymbol: UILabel!
    @IBOutlet fileprivate weak var lbRamPrice: UILabel!
    
    //EOS or Bytes
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

        lbQuantityTitle.text = LocalizedString.Wallet.Transfer.quantity
        btnApply.setTitle(LocalizedString.Wallet.Transfer.transfer, for: .normal)
        btnCancel.setTitle(LocalizedString.Common.cancel, for: .normal)
    }
    
    deinit {
        Log.d("deinit")
        bag = nil
    }
    
    func configureBuy(quantity: Double, ramPrice: Double, observer: AnyObserver<Bool>) {
          //buy
        lbBytesTitle.text = "Bytes"
        lbBytes.text = Int64(ramPrice * quantity).prettyPrinted
        lbByteSymbol.text = "Bytes"
        lbRamPrice.text = ramPrice.prettyPrinted
        
        btnApply.setTitle(LocalizedString.Wallet.Ram.buyram, for: .normal)
    
        lbQuantity.text = quantity.dot4String
        lbSymbol.text = .eos
        
        bindAction(observer: observer)
    }
    
    func configureSell(bytes: Int64, ramPrice: Double, observer: AnyObserver<Bool>) {
        //buy
        lbBytesTitle.text = LocalizedString.Wallet.Transfer.quantity
        lbBytes.text = (Double(bytes) / ramPrice).dot4String
        lbByteSymbol.text = .eos
        lbRamPrice.text = ramPrice.prettyPrinted
        
        btnApply.setTitle(LocalizedString.Wallet.Ram.sellram, for: .normal)
        
        lbQuantity.text = bytes.prettyPrinted
        lbSymbol.text = "Bytes"
        
        bindAction(observer: observer)
    }
    
    func bindAction(observer: AnyObserver<Bool>) {
        let bag = DisposeBag()
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
    
    
    static func showForBuyRam(quantity: Double, ramPrice: Double) -> Observable<Bool> {
        
        return Observable<Bool>.create({ (observer) -> Disposable in
            
            guard let popup = Bundle.main.loadNibNamed("RamPopup", owner: nil, options: nil)?.first as? RamPopup else {
                preconditionFailure("TransferPopup View did not load")
            }
            
            let window = UIApplication.shared.keyWindow!
            popup.frame = window.bounds
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(popup)
            
            popup.configureBuy(quantity: quantity, ramPrice: ramPrice, observer: observer)
            
            popup.presentAnimation()
            
            return Disposables.create {
                
            }
        })
    }
    
    static func showForSellRam(bytes: Int64, ramPrice: Double) -> Observable<Bool> {
        
        return Observable<Bool>.create({ (observer) -> Disposable in
            
            guard let popup = Bundle.main.loadNibNamed("RamPopup", owner: nil, options: nil)?.first as? RamPopup else {
                preconditionFailure("TransferPopup View did not load")
            }
            
            let window = UIApplication.shared.keyWindow!
            popup.frame = window.bounds
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(popup)
            
            popup.configureSell(bytes: bytes, ramPrice: ramPrice, observer: observer)
            
            popup.presentAnimation()
            
            return Disposables.create {
                
            }
        })
    }
    
    
}

