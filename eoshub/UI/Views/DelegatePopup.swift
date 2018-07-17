//
//  DelegatePopup.swift
//  eoshub
//
//  Created by kein on 2018. 7. 17..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class DelegatePopup: UIView {
    
    @IBOutlet fileprivate weak var container: UIView!
    @IBOutlet fileprivate weak var bgView: UIView!
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    
    @IBOutlet fileprivate weak var lbCpuQuantityTitle: UILabel!
    @IBOutlet fileprivate weak var lbCpuQuantity: UILabel!
    @IBOutlet fileprivate weak var lbNetQuantityTitle: UILabel!
    @IBOutlet fileprivate weak var lbNetQuantity: UILabel!
    @IBOutlet fileprivate weak var btnApply: UIButton!
    @IBOutlet fileprivate weak var btnCancel: UIButton!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Wallet.Transfer.popupTitle
        lbCpuQuantityTitle.text = LocalizedString.Wallet.Transfer.quantity
        lbNetQuantityTitle.text = LocalizedString.Wallet.Transfer.quantity
        btnApply.setTitle(LocalizedString.Wallet.Transfer.transfer, for: .normal)
        btnCancel.setTitle(LocalizedString.Common.cancel, for: .normal)
    }
    
    deinit {
        Log.d("deinit")
        bag = nil
    }
    
    func configure(cpu: Double, net: Double, buttonTitle: String, observer: AnyObserver<Bool>) {
        
        let bag = DisposeBag()
        
        lbCpuQuantity.text = cpu.dot4String
        lbNetQuantity.text = net.dot4String
        btnApply.setTitle(buttonTitle, for: .normal)
        
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
    
    
    static func show(cpu: Double, net: Double, buttonTitle: String) -> Observable<Bool> {
        
        return Observable<Bool>.create({ (observer) -> Disposable in
            
            guard let popup = Bundle.main.loadNibNamed("DelegatePopup", owner: nil, options: nil)?.first as? DelegatePopup else {
                preconditionFailure("TransferPopup View did not load")
            }
            
            let window = UIApplication.shared.keyWindow!
            popup.frame = window.bounds
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(popup)
            
            popup.configure(cpu: cpu, net: net, buttonTitle: buttonTitle, observer: observer)
            
            popup.presentAnimation()
            
            return Disposables.create {
                
            }
        })
        
    }
}

