//
//  Scheme.swift
//  eoshub
//
//  Created by kein on 2018. 9. 17..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

struct Scheme {
    static let eoshub = "eoshub://"

    
    /// supported scheme host
    /// - request: You can request transactions such as transfer, claim, bet, etc. to eos account or anonymous.
    enum Host: String {
//        case tx
//        case packed_tx
        case request
    }
    
    enum Parameter: String {
        case data
        case callback
    }
    
    let host: Host
    var parmas: [Parameter: String] = [:]
    
    init?(url: URL) {
        if url.scheme == Scheme.eoshub {
            return nil
        }
        
        guard let hostString = url.host, let host = Host(rawValue: hostString) else {
            Log.e("Unknown host")
            return nil
        }
        self.host = host
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems?.forEach({ (item) in
            guard let key = Parameter(rawValue: item.name) else { return }
            if let value = item.value {
                parmas[key] = value
            }
        })
    }
  
}

extension Scheme {
    
    var data: JSON? {
        guard let data = parmas[.data] else { return nil }
        let json = JSON.createJSON(from: data)
        return json
    }
    
    func getAction(actor: EOSName, authorization: Authorization) -> Contract? {
        guard let data = parmas[.data] else { return nil }
        
        let jsonString = data.replacingOccurrences(of: "+", with: " ")
                             .replacingOccurrences(of: "$0", with: actor.value)
        let json = JSON.createJSON(from: jsonString)
        
        guard let code = json?.string(for: "code"),
              let action = json?.string(for: "action"),
              let args = json?.json(for: "args") else { return nil }
        
        return Contract(code: code, action: action, args: args, authorization: authorization)
        
    }
    
}
