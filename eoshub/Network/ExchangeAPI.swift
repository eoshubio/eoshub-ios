//
//  API.swift
//  UpbitTrade
//
//  Created by kein on 2018. 1. 2..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

struct UpbitAPI: ExChangeAPI {
    fileprivate static let baseURL = "https://crix-api-endpoint.upbit.com/v1/crix/candles/"
    
    static func getTrade(period min: Int, code: String, count: Int) -> Observable<[JSON]> {
        return Observable.create({ (observer) -> Disposable in
            
            let url = UpbitAPI.baseURL + "/minutes/\(min)?code=" + code + "&count=\(count)"
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let json):
                        if let jsonArray = json as? [JSON] {
                            observer.onNext(jsonArray)
                        }
                        observer.onCompleted()
                    case .failure(let error):
                        print(error)
                    }
                    
                })
            
            return Disposables.create {
                
            }
        })
    }
    
    static func getLastPrice() -> Observable<Price> {
        return getTrade(period: 1, code: "CRIX.UPBIT.KRW-EOS", count: 1)
                    .flatMap({ (json) -> Observable<Price> in
                        if let firstTrade = json.first, let lastPrice = firstTrade.double(for: "tradePrice") {
                            return Observable.just(Price(price: lastPrice, currency: .KRW))
                        } else {
                            return Observable.error(NetworkError.emptyData)
                        }
                    })
    }
}

/*
 {"code":"CRIX.UPBIT.KRW-BTC","candleDateTime":"2018-01-02T12:40:00+00:00","candleDateTimeKst":"2018-01-02T21:40:00+09:00","openingPrice":18980000.00000000,"highPrice":19001000.00000000,"lowPrice":18980000.00000000,"tradePrice":18990000.00000000,"candleAccTradeVolume":18.82140964,"candleAccTradePrice":357374677.90878000,"timestamp":1514896859976,"unit":1}
 */

struct BitfinexAPI: ExChangeAPI {
    fileprivate static let baseURL = "https://api.bitfinex.com/v2/ticker/tEOSUSD"
    
    static func getLastPrice() -> Observable<Price> {
        
        return Observable<[Any]>.create({ (observer) -> Disposable in
            let request = Alamofire.request(baseURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
                .responseJSON(completionHandler: { (response) in
                    switch response.result {
                    case .success(let result):
                        let array = result as? [Any] ?? []
                        observer.onNext(array)
                        observer.onCompleted()
                    case  .failure(let error):
                        observer.onError(error)
                    }
                })
            
            return Disposables.create {
                request.cancel()
            }
        })
            .flatMap { (result) -> Observable<Price> in
                if result.count == 10, let lastPrice = result[6] as? Double {
                    return Observable.just(Price(price: lastPrice, currency: .USD))
                } else {
                    return Observable.error(NetworkError.emptyData)
                }
        }
    }
    
}

//[BID ,BID_SIZE, ASK, ASK_SIZE, DAILY_CHANGE, DAILY_CHANGE_PERC, LAST_PRICE, VOLUME, HIGH, LOW]
//[8.2313,6429.71149195,8.2378,10507.2969548,0.1386,0.0171,8.2386,4556957.72128894,8.2926,7.9085]


protocol ExChangeAPI {
    static func getLastPrice() -> Observable<Price>
}

struct Price {
    let price: Double
    let currency: Currency
    
    enum Currency: String {
        case KRW, USD
    }
    
    func estimatedPrice(eosQuantity: Double) -> String {
        let p = price * eosQuantity
        
        switch currency {
        case .KRW:
            return Int64(p).prettyPrinted + " " + currency.rawValue
        default:
            return p.prettyPrinted + " " + currency.rawValue
        }
        
    }
}
