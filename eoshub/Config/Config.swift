//
//  Config.swift
//  eoshub
//
//  Created by kein on 2018. 7. 14..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation

enum ChainMode {
    case mainnet, junglenet, regnet
}

struct Config {
    
    static let mode = ChainMode.mainnet

    static var eoshubHost = "https://eos-hub.io"
    
    static var eoshubMedium = "https://medium.com/@eoshub.io"
    
    static let termForBuyers = "https://github.com/eoshubio/documents/blob/master/TermsForBuyers.md"
    
    static let eosConstitution = "https://github.com/EOS-Mainnet/governance/blob/master/eosio.system/eosio.system-clause-constitution-rc.md"
    
    static let donationAccount = "eoshuborigin"
    
    static var host: String {
        switch mode {
        case .junglenet:
            return "https://eos-hub.io:8443"
        case .mainnet:
            return "https://eos.greymass.com"
        default:
            preconditionFailure()
        }
    }
    
    static var eosInfo: TokenInfo {
        switch mode {
        case .junglenet:
            return TokenInfo(contract: "eosio.token", symbol: "EOS", name: "EOS")
        case .mainnet:
            return TokenInfo(contract: "eosio.token", symbol: "EOS", name: "EOS")
        default:
            preconditionFailure()
        }
    }
    
    static var pandoraInfo: TokenInfo {
        switch mode {
        case .junglenet:
            return TokenInfo(contract: "eoshubtokenz", symbol: "PDR", name: "Pandora")
        case .mainnet:
            return TokenInfo(contract: "eoshubtokenz", symbol: "PDR", name: "Pandora")//TODO: issue pandora
        default:
            preconditionFailure("Not implemented")
        }
    }
    
    static var apiServers: [String] {
        return ["https://eos.greymass.com",
                "https://api.main-net.eosnodeone.io",
                "https://api.cypherglass.com",
                "https://publicapi-mainnet.eosauthority.com",
                "https://mainnet.eoscanada.com"]
    }
    
    static var versionString: String {
        let shortVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0"
        return shortVersion
    }
    
    static var txHost: String = "https://eosflare.io/tx/"
    
    
    static let limitResCPU: Int64 = 500
    static let limitResNet: Int64 = 1000
    static let limitResRAM: Int64 = 2000
    
    static let maxPinCount = 6
}
