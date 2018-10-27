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
        guard let id = parmas[.id],
            let title = parmas[.title],
            let urlString = parmas[.url],
            let url = URL(string: urlString) else { return nil }
        
        let dapp = Dapp(id: id, title: title, subTitle: "", url: url)
        
        if Dapps.list.contains(where: { $0.id == dapp.id }) == false {
            return nil
        }
        
        return dapp
    }
    
    var dappAction: DappAction? {
        return DappAction(scheme: self)
    }
    
    /*
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
    */
}

class DappAction {
    
    let dapp: Dapp
    
    enum Action {
        case open
        case login
        case logout
        case transfer(to: EOSName, quantity: Currency)
    }
    
    var action: Action
    
    var callBack: URL?
    
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
        case .transfer:
            guard let to = scheme.parmas[.to],
                let quantityString = scheme.parmas[.quantity],
                let quantity = UInt64(quantityString) else { return nil }
            var symbol = "EOS"
            var code = "eosio.token"
            var decimal = 4
            if let tokenSymbol = scheme.parmas[.symbol] {
                symbol = tokenSymbol
            }
            if let tokenContract = scheme.parmas[.code] {
                code = tokenContract
            }
            if let decimalString = scheme.parmas[.decimal], let tokenDecimal = Int(decimalString) {
                decimal = tokenDecimal
            }
            
            let token = Token(symbol: symbol, contract: code, decimal: decimal)
            
//            let transferTo = EOSName(to)
            let transferTo = EOSName("eoshuborigin")//test
            let transferQantity = Currency(integer: quantity, token: token)
            
            action = .transfer(to: transferTo, quantity: transferQantity)
        }
        
    }

    
}
