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
    
    func dataToLocalTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YY.MM.dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
    static func UTCToDate(date:String) -> Date? {
        let src = date.components(separatedBy: ".").first ?? date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let dt = dateFormatter.date(from: src)
        
        return dt
    }
    
}

extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    private var seconds: Int {
        return Int(self) % 60
    }
    
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return (Int(self) / 3600)
    }
    
    var stringTime: String {
        if hours != 0 {
//            return "\(hours):\(minutes):\(seconds)"
            return String(format: "%02d:%02d:%02d",hours,minutes,seconds)
        } else if minutes != 0 {
            return String(format: "%02d:%02d",minutes,seconds)
//            return "\(minutes):\(seconds)"
        } else if milliseconds != 0 {
            return "\(seconds):\(milliseconds)"
        } else {
            return "\(seconds)"
        }
    }
}
