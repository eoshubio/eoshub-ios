
import Foundation
import UIKit
//import Crashlytics

class Log {
    public enum LogLevel: Int {
        case info, debug, warning, error, fatal
        
        var description: String {
            switch self {
            case .info:
                return "i"
            case .debug:
                return "d"
            case .warning:
                return "w"
            case .error:
                return "e"
            case .fatal:
                return "f"
            }
        }
    }
    
//#if DEBUG
    public static var logLevel: LogLevel = .info
//#else
//    public static var logLevel: LogLevel = .warning
//#endif
    
    fileprivate class func EHLog( level: LogLevel = .warning,
              message: Any,
                file: String = #file,
              function: String = #function,
              line: Int = #line ) {
        
        if level.rawValue < Log.logLevel.rawValue {
            return
        }
        
        let fileName = file.components(separatedBy: "/").last ?? file
        
        let string = "[\(level.description)] \"\(message)\" (\(fileName)-\(function)[\(line)]), Thread0: \(Thread.isMainThread))"
        
        NSLog("%@",string)
//        #if DEBUG
//            CLSNSLogv("%@", getVaList([string]))
//        #else
//            CLSLogv("%@", getVaList([string]))
//        #endif
        
    }
    
    //info
    class func i(_ message: Any,
                     file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        EHLog(level: .info, message: message, file:file, function: function, line: line)
    }
    //debug
    class func d(_ message: Any,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        EHLog(level: .debug, message: message, file:file, function: function, line: line)
    }
    //warning
    class func w(_ message: Any,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        EHLog(level: .warning, message: message, file:file, function: function, line: line)
    }
    //error
    class func e(_ message: Any,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        EHLog(level: .error, message: message, file:file, function: function, line: line)
    }
    //fatal
    class func f(_ message: Any,
                 file: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        EHLog(level: .fatal, message: message, file:file, function: function, line: line)
    }
    
}



func DebugAlert(message: String, to vc: UIViewController) {
    #if DEBUG
        let alert = UIAlertController(title: "Internal Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        alert.show(vc, sender: nil)
    #endif
}



func dLogStack() {
    print("Call stack: ")
        Thread.callStackSymbols.forEach{ print($0)}
        print("------")

}


