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
                    return Observable.error(EOSErrorType.emptyData)
                }
            })
    }
    
    static func getActions(accountName: String) -> Observable<JSON> {

        let params: JSON = ["account_name": accountName, "pos": -1, "offset": -200]
        
        return EOSAPI.History.get_actions
                    .responseJSON(method: .post, parameter: params, encoding: JSONEncoding.default)
        
        
    }
    
    //MARK: Wallet
    
//    static func walletCreate(name: String) -> Observable<Wallet> {
//        return EOSAPI.Wallet.create
//                .responseString(method: .post, parameter: [StringEncoding.key: name], encoding: StringEncoding.default)
//                .flatMap({ (pw) -> Observable<Wallet> in
//                    return Observable.just(Wallet(name: name, password: pw))
//                })
//    }
//
//    static func walletImportKey(key: String, to wallet: Wallet) -> Observable<Wallet> {
//        return EOSAPI.Wallet.import_key
//                .response(method: .post, array: [wallet.name, key])
//                .flatMap({ (_) -> Observable<Wallet> in
//                    return Observable.just(wallet)
//                })
//    }
//
//    static func walletGetKeys() -> Observable<[String]> {
//        return EOSAPI.Wallet.get_public_keys
//                .responseArray(method: .post, parameter: nil, encoding: URLEncoding.default)
//                .flatMap({ (array) -> Observable<[String]> in
//                    if let array = array as? [String] {
//                        return Observable.just(array)
//                    } else {
//                        return Observable.just([])
//                    }
//                })
//    }
//
//    static func walletUnlock(array: [String]) -> Observable<Bool> {
//
//        return EOSAPI.Wallet.unlock
//                .responseJSON(method: .post, parameter: [ArrayEncoding.key: array], encoding: ArrayEncoding.default)
//                .flatMap({_ in return Observable.just(true)})
//                .catchError({ (error) -> Observable<Bool> in
//                    //TODO: If wallet is already opened, return true
//                    return Observable.just(false)
//                })
//    }
//
//    static func walletCreateKey(wallet: Wallet) -> Observable<Wallet> {
//        return EOSAPI.Wallet.create_key
//                .responseString(method: .post, parameter: [ArrayEncoding.key: [wallet.name, "K1"]], encoding: ArrayEncoding.default)
//                .flatMap({ (key) -> Observable<Wallet> in
//                    wallet.publicKey = key
//                    return Observable.just(wallet)
//                })
//
//    }
    
//    static func signTransaction(array: [Any]) -> Observable<JSON> {
//
//        return EOSAPI.Wallet.sign_transaction
//                .responseJSON(method: .post, parameter: [ArrayEncoding.key: array], encoding: ArrayEncoding.default)
//    }
    
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
                
                //sign
                wallet.sign(txn: signTrx, cid: data.blockInfo.chainId)
                
                return Observable.just(signTrx)

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
                let action = Action(account: contract.code, action: contract.action.rawValue, authorization: contract.authorization, binary: binary.bin)
                return Observable.just(action)
            }
    }
    
    static func makeActions(contracts: [Contract]) -> Observable<[Action]>  {
        let rxActions = contracts.map{ makeAction(contract: $0)}
        return Observable.zip(rxActions)
    }
    
    
}


extension RxEOSAPI {
    //MARK: Create Wallet & Account
    static func createAccount(name: String, authorization: Authorization) -> Observable<Void> {
        //1. create wallet
        
//        return walletCreate(name: name)
//            .flatMap { (wallet) -> Observable<Wallet> in
//                //2. import eosio key
//                return walletImportKey(key: EOSHub.privateKey, to: wallet)
//            }
//            .flatMap { (wallet) -> Observable<Wallet> in
//                //3. create key for new account
//                return walletCreateKey(wallet: wallet)
//            }
//            .flatMap { (wallet) -> Observable<Wallet> in
////                WalletManager.shared.addWallet(wallet: wallet)
//                let minCurrency = Currency(currency: "0.0001 EOS")!
//                let authority = Authority(key: wallet.publicKey)
//                let contract = Contract.newAccount(name: name, owner: authority, active: authority, authorization: Authorization.eoshub)
////                let buyram = Contract.buyram(payer: EOSHub.account, receiver: name, quant: minCurrency)
//                let buyrambytes = Contract.buyramBytes(payer: EOSHub.account, receiver: name, bytes: 8024)
//                let delegatebw = Contract.delegateBW(from: EOSHub.account, receiver: name, cpu: minCurrency, net: minCurrency)
//                return RxEOSAPI.pushContract(contracts: [contract, buyrambytes, delegatebw], wallet: wallet)
//                    .flatMap({ (_) -> Observable<Wallet> in
//                        //account 생성시에만 wallet을 저장하게 한다.
//                        return Observable.just(wallet)
//                    })
//            }
        return Observable.empty()
    }
    
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
    
   
    
    //MARK: Transfer currency
    static func sendCurrency(from: String, to: String, quantity: Currency, memo: String = "", wallet: Wallet) -> Observable<JSON> {
      
        let code = quantity.token.contract
        
        let contract = Contract.transfer(code: code, from: from, to: to, quantity: quantity, memo: memo)

        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
        
    }
    
    //MARK: vote bp
    static func voteBPs(voter: String, producers: [String], wallet: Wallet) -> Observable<JSON> {
        let contract = Contract.voteProducer(voter: voter, producers: producers)
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
    static func delegatebw(account: String, cpu: Currency, net: Currency, wallet: Wallet) -> Observable<JSON> {
        
        let contract = Contract.delegateBW(from: account, receiver: account, cpu: cpu, net: net)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
        
    }
    
    static func undelegatebw(account: String, cpu: Currency, net: Currency, wallet: Wallet) -> Observable<JSON> {
        
        let contract = Contract.undelegateBW(from: account, receiver: account, cpu: cpu, net: net)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
        
    }
    
    //MARK: Ram
    static func buyram(account: String, quantity: Currency, wallet: Wallet) -> Observable<JSON> {
        let contract = Contract.buyram(payer: account, receiver: account, quant: quantity)
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
    }
    
    static func sellram(account: String, bytes: Int64, wallet: Wallet) -> Observable<JSON> {
        let contract = Contract.sellram(account: account, bytes: bytes)
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
        
        let rxGetTokens = tokens.map { (preferToken) -> Observable<Currency> in
            return RxEOSAPI.getBalance(account: account.account, contract: preferToken.contract, symbol: preferToken.symbol)
        }
        
        return Observable.zip(rxGetTokens)
    }
    
    //MARK: Transaction History
    static func getTxHistory(account: String)  -> Observable<[Tx]> {
        return getActions(accountName: account)
            .flatMap { (json) -> Observable<[Tx]> in
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
}

