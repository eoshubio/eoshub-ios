//
//  RxEOSAPI.swift
//  eosio-api
//
//  Created by kein on 2018. 6. 14..
//  Copyright © 2018년 kein. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

struct RxEOSAPI {
    //MARK: Chain
    static func jsonToBin(json: JSON) -> Observable<BinaryString> {
        
        return EOSAPI.Chain.abi_json_to_bin
            .responseJSON(method: .post, parameter: json, encoding: JSONEncoding.default)
            .flatMap({ (json) -> Observable<BinaryString> in
                guard let bin = BinaryString(json: json) else { return Observable.error(EOSErrorType.emptyData) }
                return Observable.just(bin)
            })
    }
    
    static func getInfo() -> Observable<BlockInfo> {
        
        return EOSAPI.Chain.get_info
            .responseJSON(method: .get, parameter: nil, encoding: URLEncoding.default)
            .flatMap({ (json) -> Observable<BlockInfo> in
                guard let blockInfo = BlockInfo(json: json) else { return Observable.error(EOSErrorType.emptyData) }
                return Observable.just(blockInfo)
            })
    }
    
    static func getBlock(json: JSON) -> Observable<Block> {
        
        return EOSAPI.Chain.get_block
                .responseJSON(method: .post, parameter: json, encoding: JSONEncoding.default)
                .flatMap({ (json) -> Observable<Block> in
                    guard let block = Block(json: json) else { return Observable.error(EOSErrorType.emptyData)}
                    return Observable.just(block)
                })
    }
    
    static func getRequiredKeys(json: JSON) -> Observable<JSON> {
        return EOSAPI.Chain.get_required_keys
            .responseJSON(method: .post, parameter: json, encoding: JSONEncoding.default)
    }
    
    static func getBalance(account: String, contract: String, symbol: String) -> Observable<Currency> {
        
        let params = ["account": account, "code": contract, "symbol": symbol]
        let token = Token(symbol: symbol, contract: contract)
        
        return EOSAPI.Chain.get_currency_balance
            .responseArray(method: .post, parameter: params, encoding: JSONEncoding.default)
            .flatMap({ (resArray) -> Observable<Currency> in
                if let currencyArray = resArray as? [String] {
                    if let result = currencyArray.compactMap({ Currency.create(stringValue: $0, contract: contract) }).first {
                        return Observable.just(result)
                    } else {
                        return Observable.just(Currency(balance: 0, token: token))
                    }
                } else {
                    return Observable.error(EOSErrorType.emptyData)
                }
            })
    }
    
    static func getExistCurrencyStats(token: Token) -> Observable<Bool> {
        return EOSAPI.Chain.get_currency_stats
                .responseJSON(method: .post,
                          parameter: ["code": token.contract, "symbol": token.symbol],
                          encoding: JSONEncoding.default)
                .flatMap({ (json) -> Observable<Bool> in
                    return Observable.just(json.count > 0)
                })
        
    }
    
    static func pushTransaction(json: JSON) -> Observable<JSON> {
        return EOSAPI.Chain.push_transaction
            .responseJSON(method: .post, parameter: json, encoding: JSONEncoding.default)
        
    }
    
    //MARK: History
    static func getAccountFromPubKey(pubKey: String) -> Observable<String> {
        return EOSAPI.History.get_key_accounts
            .responseJSON(method: .post, parameter: ["public_key": pubKey], encoding: JSONEncoding.default)
            .flatMap({ (json) -> Observable<String> in
                if let accountName = json.arrayString(for: "account_names")?.first {
                    return Observable.just(accountName)
                } else {
                    return Observable.error(EOSErrorType.emptyData)
                }
            })
    }
    
    static func getPubKeyFromAccount(account: String) -> Observable<String> {
        return getAccount(name: account)
            .flatMap({ (ac) -> Observable<String> in
                if let activePubKey = ac.permissions.last?.keys.last {
                    return Observable.just(activePubKey.key)
                } else {
                    return Observable.just("")
                }
            })
    }
    
    static func getActions(accountName: String) -> Observable<JSON> {

        let params: JSON = ["account_name": accountName, "pos": -1, "offset": -100]
        
        return EOSAPI.History.get_actions
                    .responseJSON(method: .post, parameter: params, encoding: JSONEncoding.default)
        
        
    }
    
    static func getTransaction(txid: String) -> Observable<JSON> {
        let params: JSON = ["id": txid]
        return EOSAPI.History.get_transaction
                    .responseJSON(parameter: params)
    }
    
    
    //MARK: Contract
    static func pushContract(contracts: [Contract], wallet: Wallet) -> Observable<JSON> {
        
        //1. unlock wallet
        return RxEOSAPI.getInfo()
            .flatMap { (blockInfo) -> Observable<(blockInfo: BlockInfo ,block: Block)> in
                //3. get block
                return RxEOSAPI.getBlock(json: ["block_num_or_id": blockInfo.headBlockNum])
                    .flatMap({ (block) -> Observable<(blockInfo: BlockInfo , block: Block)> in
                        return Observable.just((blockInfo: blockInfo, block: block))
                    })
            }
            .flatMap({ (data) -> Observable<(blockInfo: BlockInfo, block: Block, actions: [Action])> in
                //3. make binaries -> make actions
                return makeActions(contracts: contracts)
                    .flatMap({ (actions) -> Observable<(blockInfo: BlockInfo , block: Block, actions: [Action])> in
                        return Observable.just((blockInfo: data.blockInfo, block: data.block, actions: actions))
                    })
            })
            .flatMap { (data) -> Observable<SignedTransaction> in
                //5. sign transaction
                let trx = Transaction(block: data.block, actions: data.actions).json
                
                let signTrx = SignedTransaction(json: trx)!
                
                return wallet.rx_sign(txn: signTrx, cid: data.blockInfo.chainId)
            }
            .flatMap { (trx) -> Observable<JSON> in
                Log.d(trx)
                //6. push transaction
//                guard let input = SignedTransaction(json: json) else { return Observable.error(EOSErrorType.invalidFormat) }
                let packedTransaction = PackedTransaction(signTxn: trx)
                return RxEOSAPI.pushTransaction(json: packedTransaction.json)
        }
    }
    
    static func makeAction(contract: Contract) -> Observable<Action> {
        return RxEOSAPI.jsonToBin(json: contract.json)
            .flatMap { (binary) -> Observable<Action> in
                let action = Action(account: contract.code, action: contract.action, authorization: contract.authorization, binary: binary.bin)
                return Observable.just(action)
            }
    }
    
    static func makeActions(contracts: [Contract]) -> Observable<[Action]>  {
        let rxActions = contracts.map{ makeAction(contract: $0)}
        return Observable.zip(rxActions)
    }
    
    
}


extension RxEOSAPI {

    
    //MARK: Get account
    static func getAccount(name: String) -> Observable<Account> {
        return EOSAPI.Chain.get_account
                .responseJSON(method: .post, parameter: ["account_name": name], encoding: JSONEncoding.default)
                .flatMap({ (json) -> Observable<Account> in
                    if let account = Account(json: json) {
                        return Observable.just(account)
                    } else {
                        return Observable.error(EOSErrorType.emptyData)
                    }
                })
    }
    
    static func getListBW(name: String) -> Observable<JSON> {
        return EOSAPI.Chain.get_table_rows
            .responseJSON(method: .post, parameter: ["scope": name, "json": true, "code": "eosio", "table": "delband"],
                          encoding: JSONEncoding.default)
    }
    
   
    //MARK: Update Auth
    static func updateAuth(account: String, permission: Permission, auth: Authority, wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
        let contract = Contract.updateauth(account: account, permission: permission, auth: auth, authorization: authorization)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
    }
    
    
    //MARK: Transfer currency
    static func sendCurrency(from: String, to: String, quantity: Currency, memo: String = "", wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
      
        let code = quantity.token.contract
        
        let contract = Contract.transfer(code: code, from: from, to: to, quantity: quantity, memo: memo, authorization: authorization)

        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
        
    }
    
    //MARK: vote bp
    static func voteBPs(voter: String, producers: [String], wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
        let contract = Contract.voteProducer(voter: voter, producers: producers, authorization: authorization)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
    }
    
    //MARK: Get Currency EOS
    static func getCurrencyBalance(name: String, symbol: String) -> Observable<[Currency]> {
        let input = ["account": name, "symbol": symbol, "code": "eosio.token"]
        return EOSAPI.Chain.get_currency_balance
                .responseArray(method: .post, parameter: input, encoding: JSONEncoding.default)
                .flatMap { (result) -> Observable<[Currency]> in
                    let currency = result.compactMap { $0 as? String }.compactMap(Currency.init)
                    return Observable.just(currency)
                }
    }
    
    //MARK: Delegate Bandwidth
    static func delegatebw(account: String, cpu: Currency, net: Currency, wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
        
        let contract = Contract.delegateBW(from: account, receiver: account, cpu: cpu, net: net, authorization: authorization)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
        
    }
    
    static func undelegatebw(account: String, cpu: Currency, net: Currency, wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
        
        let contract = Contract.undelegateBW(from: account, receiver: account, cpu: cpu, net: net, authorization: authorization)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
        
    }
    
    //MARK: Refund
    static func refund(owner: String, wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
        let contract = Contract.refund(owner: owner, authorization: authorization)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
    }
    
    //MARK: Ram
    static func buyram(account: String, quantity: Currency, wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
        let contract = Contract.buyram(payer: account, receiver: account, quant: quantity, authorization: authorization)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
    }
    
    static func sellram(account: String, bytes: Int64, wallet: Wallet, authorization: Authorization) -> Observable<JSON> {
        let contract = Contract.sellram(account: account, bytes: bytes, authorization: authorization)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
    }
    
    //MARK: Get Producer
    static func getProducers(limit: Int) -> Observable<BlockProducers> {
        let params: JSON = ["limit": limit, "lower_bound": "", "json": "true"]
        return EOSAPI.Chain.get_producers
                .responseJSON(method: .post, parameter: params, encoding: JSONEncoding.default)
                .flatMap({ (json) -> Observable<BlockProducers> in
                    if let result = BlockProducers(json: json) {
                        return Observable.just(result)
                    } else {
                        return Observable.error(EOSErrorType.emptyData)
                    }
                })
    }
    
    //MARK: Tokens
    static func getTokens(account: EHAccount, tokens: [Token]) -> Observable<[Currency]> {
        
        if tokens.count == 0 { return Observable.just([]) }
        
        let rxGetTokens = tokens.map { (preferToken) -> Observable<Currency> in
            return RxEOSAPI.getBalance(account: account.account, contract: preferToken.contract, symbol: preferToken.symbol)
        }
        
        return Observable.zip(rxGetTokens)
    }
    
    //MARK: Transaction History
    static func getTxHistory(account: String)  -> Observable<[Tx]> {
        return getActions(accountName: account)
            .flatMap { (json) -> Observable<[Tx]> in
                
                if let errors = json.string(for: "errors") {
                    return Observable.error( EOSResponseError(code: 0, stack: [], name: "Exception", what: errors))
                }
                
                guard let actions = json.arrayJson(for: "actions") else { return Observable.error(EOSErrorType.emptyData) }
                let txs = actions.compactMap(Tx.init)
                let txSet = Set(txs)
                return Observable.just(Array(txSet))
            }
    }
    
    //MARK: Ram market
    static func getRamPrice()  -> Observable<RamPrice> {
        let params: JSON = ["json": true,
                           "code": "eosio",
                           "scope": "eosio",
                           "table": "rammarket",
                           "table_key": "",
                           "lower_bound": "",
                           "upper_bound": "",
                           "limit": 10
                           ]
        return EOSAPI.Chain.get_table_rows
                .responseJSON(method: .post, parameter: params, encoding: JSONEncoding.default)
                .flatMap({ (json) -> Observable<RamPrice> in
                    if let rows = json.arrayJson(for: "rows"),
                        let price = rows.compactMap(RamPrice.init).first {
                        return Observable.just(price)
                    }
                    return Observable.error(EOSErrorType.emptyData)
                })
        
    }
    
    //MARK: ABI
    static func getContractInfo(code: String) -> Observable<ABI> {
        return EOSAPI.Chain.get_abi
            .responseJSON(method: .post, parameter: ["account_name": code], encoding: JSONEncoding.default)
            .flatMap { (json) -> Observable<ABI> in
                if let abi = ABI(json: json) {
                    return Observable.just(abi)
                } else {
                    return Observable.error(EOSErrorType.emptyData)
                }
            }
            
    }
    
    
}

