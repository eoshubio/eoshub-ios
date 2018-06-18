//
//  Date+extension.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 17..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation

extension Date {
    
    func increase(time: TimeInterval) -> Date {
        return addingTimeInterval(time)
    }
    
    func dateToUTC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter.string(from: self)
    }
    
    static func UTCToDate(date:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: date)
        return dt
    }
    
}
