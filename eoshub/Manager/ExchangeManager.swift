//
//  ExchangeManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 23..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ExchangeManager {
    static let shared = ExchangeManager()
    
    fileprivate let pollingScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    
    fileprivate var api: [Price.Currency: ExchangeAPI.Type] = [:]
    
    var currency: Price.Currency {
        didSet {
            polling()
        }
    }
    
    var lastPrice = Variable<Price?>(nil)
    
    private var bag: DisposeBag?
    
    init() {
        api[.KRW] = BithumbAPI.self
        api[.USD] = BitfinexAPI.self
        
        currency = Price.Currency(rawValue: Preferences.shared.preferCurrency) ?? .KRW
        
        polling()
    }
    
    func polling() {
        self.bag = nil
        let bag = DisposeBag()
        self.bag = bag
        let _ = Observable<Int>
            .interval(1, scheduler: pollingScheduler)
            .flatMap({ [unowned self](_) -> Observable<Price?> in
                guard let api = self.api[self.currency] else { return Observable.error(NetworkError.unknownAPI) }
                return api.getLastPrice()
            })
            .catchErrorJustReturn(nil)
            .subscribe(onNext: { [unowned self](price) in
                self.lastPrice.value = price
                }, onError: { (error) in
                    Log.e(error)
            } ) {
                Log.e("disposed")
            }
            .disposed(by: bag)
    }
    
    
    
}
