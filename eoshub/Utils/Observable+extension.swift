//
//  Observable+extension.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation


import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    
    var skipDoubleTap: Observable<E> {
//        return debounce(0.3, scheduler: MainScheduler.instance)
        return throttle(0.3, scheduler: MainScheduler.instance)
    }
}

extension Reactive where Base: UIButton {
    
    /// Reactive wrapper for `TouchUpInside` control event.
    /// debounce 0.3 sec at main thread
    public var singleTap: Observable<Void> {
        return controlEvent(.touchUpInside).skipDoubleTap
    }
}


