//
//  TokenAddPopup.swift
//  eoshub
//
//  Created by kein on 2018. 7. 27..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TokenAddPopup: UIView {
    
    @IBOutlet fileprivate weak var container: UIView!
    @IBOutlet fileprivate weak var bgView: UIView!
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var lbContract: UILabel!
    @IBOutlet fileprivate weak var txtContract: AccountTextField!
    @IBOutlet fileprivate weak var lbSymbol: UILabel!
    @IBOutlet fileprivate weak var txtSymbol: UITextField!
    @IBOutlet fileprivate weak var btnAdd: UIButton!
    @IBOutlet fileprivate weak var btnCancel: UIButton!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        lbTitle.text = LocalizedString.Token.Add.title
        lbContract.text = LocalizedString.Token.Add.contract
        txtContract.placeholder = LocalizedString.Token.Add.contractEx
        lbSymbol.text = LocalizedString.Token.Add.symbol
        txtSymbol.placeholder = LocalizedString.Token.Add.symbolEx
        
        btnAdd.setTitle(LocalizedString.Token.add, for: .normal)
        btnCancel.setTitle(LocalizedString.Common.cancel, for: .normal)
        
       
    }
    
    private func isValid() -> ([Bool]) -> Observable<Bool> {
        return { checklist in
            for valid in checklist {
                if valid == false {
                    return Observable.just(false)
                }
            }
            
            return Observable.just(true)
        }
    }
    
    deinit {
        Log.d("deinit")
        bag = nil
    }
    
    func configure(observer: AnyObserver<TokenInfo>) {
        

        let bag = DisposeBag()

        let code = txtContract.rx.text.orEmpty
            .flatMap { (contract) -> Observable<Bool> in
                let validate = Validator.accountName(name: contract)
                return Observable.just(validate)
        }
        
        let symbol = txtContract.rx.text.orEmpty
            .flatMap { (symbol) -> Observable<Bool> in
                return Observable.just(symbol.count > 0)
        }
        
        Observable.combineLatest([code, symbol])
            .flatMap(isValid())
            .bind(to: btnAdd.rx.isEnabled)
            .disposed(by: bag)
        
        txtContract.becomeFirstResponder()
        
        txtContract.rx.text.orEmpty
            .subscribe(onNext: { [weak self](text) in
                self?.txtContract.text = text.lowercased()
            })
            .disposed(by: bag)
        
        txtContract.rx.controlEvent(UIControlEvents.editingDidEnd)
            .subscribe(onNext: { [weak self] (_) in
                self?.txtSymbol.becomeFirstResponder()
            })
            .disposed(by: bag)
        
        txtSymbol.rx.text.orEmpty
            .subscribe(onNext: { [weak self](text) in
                self?.txtSymbol.text = text.uppercased()
            })
            .disposed(by: bag)
        
        btnAdd.rx.singleTap
            .bind { [weak self] in
                
                guard let code = self?.txtContract.text,
                        let symbol = self?.txtSymbol.text else { return }
                
                let tokenInfo = TokenInfo(contract: code, symbol: symbol, name: nil)
                
                observer.onNext(tokenInfo)
                observer.onCompleted()
                self?.dismiss()
            }
            .disposed(by: bag)

        btnCancel.rx.singleTap
            .bind { [weak self] in
                
                observer.onError(EOSHubError.userCanceled)
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
    
    
    static func show() -> Observable<TokenInfo> {
        
        return Observable<TokenInfo>.create({ (observer) -> Disposable in
            
            guard let popup = Bundle.main.loadNibNamed("TokenAddPopup", owner: nil, options: nil)?.first as? TokenAddPopup else {
                preconditionFailure("TransferPopup View did not load")
            }
            
            
            
            let window = UIApplication.shared.keyWindow!
            popup.frame = window.bounds
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(popup)
            
            popup.configure(observer: observer)
            
            popup.presentAnimation()
            
            return Disposables.create {
                
            }
        })
        
    }
}
