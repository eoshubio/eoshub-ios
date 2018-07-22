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
    
    fileprivate var api: [Price.Currency: ExChangeAPI.Type] = [:]
    
    var currency: Price.Currency = .KRW
    
    var lastPrice = Variable<Price?>(nil)
    
    private let bag = DisposeBag()
    
    init() {
        api[.KRW] = UpbitAPI.self
        api[.USD] = BitfinexAPI.self
        
        polling()
    }
    
    func polling() {
        let _ = Observable<Int>
            .interval(1, scheduler: pollingScheduler)
            .flatMap({ [unowned self](_) -> Observable<Price> in
                guard let api = self.api[self.currency] else { return Observable.error(NetworkError.unknownAPI) }
                return api.getLastPrice()
            })
            .subscribe(onNext: { [unowned self](price) in
                self.lastPrice.value = price
            })
            .disposed(by: bag)
    }
    
    
    
}
