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
        case dapp
        case request
    }
    
    enum Action: String {
        case open
        case transfer
    }
    
    enum Parameter: String {
        case id
        case title
        case url
        case to
        case quantity
        case symbol
        case decimal
        case memo
        case code
        case data
        case callback
    }
    
    let host: Host
    var action: Action? = nil
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
        
        if let path = url.path.components(separatedBy: "/").last, let action = Action(rawValue: path) {
            self.action = action
        }
        
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
    
    var dapp: Dapp? {
        guard let id = parmas[.id] else { return nil }
        return Dapps.list.first(where: {$0.id == id})
    }
    
    var dappAction: DappAction? {
        return DappAction(scheme: self)
    }
}

class DappAction {
    
    let dapp: Dapp
    
    enum Action {
        case open
//        case login //deprecated
//        case logout
//        case transfer(to: EOSName, quantity: Currency, memo: String)
    }
    
    var action: Action = .open
    
    var callBack: URL?
    
    init(dapp: Dapp) {
        self.dapp = dapp
        action = .open
    }
    
    init?(scheme: Scheme) {
        guard scheme.host == .dapp, scheme.action != nil else { return nil }
        
        if let dapp = scheme.dapp {
            self.dapp = dapp
        } else if let dappId = scheme.parmas[.id], let dapp = Dapps.list.filter({ $0.id == dappId }).first {
            self.dapp = dapp
        } else {
            return nil
        }
        
        switch scheme.action! {
        case .open:
            action = .open
        default:
            break
        }
        
    }

    
}
