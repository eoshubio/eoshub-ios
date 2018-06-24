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
    
    static func pushTransaction(json: JSON) -> Observable<JSON> {
        return EOSAPI.Chain.push_transaction
            .responseJSON(method: .post, parameter: json, encoding: JSONEncoding.default)
        
    }
    
    //MARK: Wallet
    
    static func walletCreate(name: String) -> Observable<Wallet> {
        return EOSAPI.Wallet.create
                .responseString(method: .post, parameter: [StringEncoding.key: name], encoding: StringEncoding.default)
                .flatMap({ (pw) -> Observable<Wallet> in
                    return Observable.just(Wallet(name: name, password: pw))
                })
    }
    
    static func walletImportKey(key: String, to wallet: Wallet) -> Observable<Wallet> {
        return EOSAPI.Wallet.import_key
                .response(method: .post, array: [wallet.name, key])
                .flatMap({ (_) -> Observable<Wallet> in
                    return Observable.just(wallet)
                })
    }
    
    static func walletGetKeys() -> Observable<[String]> {
        return EOSAPI.Wallet.get_public_keys
                .responseArray(method: .post, parameter: nil, encoding: URLEncoding.default)
                .flatMap({ (array) -> Observable<[String]> in
                    if let array = array as? [String] {
                        return Observable.just(array)
                    } else {
                        return Observable.just([])
                    }
                })
    }
    
    static func walletUnlock(array: [String]) -> Observable<Bool> {
        
        return EOSAPI.Wallet.unlock
                .responseJSON(method: .post, parameter: [ArrayEncoding.key: array], encoding: ArrayEncoding.default)
                .flatMap({_ in return Observable.just(true)})
                .catchError({ (error) -> Observable<Bool> in
                    //TODO: If wallet is already opened, return true
                    return Observable.just(false)
                })
    }
    
    static func walletCreateKey(wallet: Wallet) -> Observable<Wallet> {
        return EOSAPI.Wallet.create_key
                .responseString(method: .post, parameter: [ArrayEncoding.key: [wallet.name, "K1"]], encoding: ArrayEncoding.default)
                .flatMap({ (key) -> Observable<Wallet> in
                    wallet.publicKey = key
                    return Observable.just(wallet)
                })
        
    }
    
    static func signTransaction(array: [Any]) -> Observable<JSON> {
        
        return EOSAPI.Wallet.sign_transaction
                .responseJSON(method: .post, parameter: [ArrayEncoding.key: array], encoding: ArrayEncoding.default)
    }
    
    //MARK: Contract
    static func pushContract(contracts: [Contract], wallet: Wallet) -> Observable<JSON> {
        
        //1. unlock wallet
        return RxEOSAPI.walletUnlock(array: wallet.paramter)
            .flatMap { (_) -> Observable<BlockInfo> in
                //2. get block info
                return RxEOSAPI.getInfo()
            }
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
            
            .flatMap({ (data) -> Observable<(blockInfo: BlockInfo, block: Block, actions: [Action], keys: [String])> in
                //4. get requried keys
                let trx = Transaction(block: data.block, actions: data.actions)
                var input: JSON = [:]
                input["available_keys"] = WalletManager.shared.getKeys()
                input["transaction"] = trx.json
                return RxEOSAPI.getRequiredKeys(json: input)
                    .flatMap({ (response) -> Observable<(blockInfo: BlockInfo, block: Block, actions: [Action], keys: [String])> in
                        let keys = response["required_keys"] as? [String] ?? [EOSHub.publicKey]
                        return Observable.just((blockInfo: data.blockInfo, block: data.block, actions: data.actions, keys: keys))
                    })
            })
            .flatMap { (data) -> Observable<JSON> in
                //5. sign transaction
                let trx = Transaction(block: data.block, actions: data.actions).json
                let input: [Any] = [trx, data.keys, data.blockInfo.chainId] //transaction, keys, chainid
                return RxEOSAPI.signTransaction(array: input)
            }
            .flatMap { (json) -> Observable<JSON> in
                //6. push transaction
                guard let input = SignedTransaction(json: json) else { return Observable.error(EOSErrorType.invalidFormat) }
                print(input)
                return RxEOSAPI.pushTransaction(json: input.json)
        }
    }
    
    static func makeAction(contract: Contract) -> Observable<Action> {
        return RxEOSAPI.jsonToBin(json: contract.json)
            .flatMap { (binary) -> Observable<Action> in
                let action = Action(account: contract.code, name: contract.action, authorization: contract.authorization, data: binary.bin)
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
    static func createAccount(name: String, authorization: Authorization) -> Observable<Wallet> {
        //1. create wallet
        
        return walletCreate(name: name)
            .flatMap { (wallet) -> Observable<Wallet> in
                //2. import eosio key
                return walletImportKey(key: EOSHub.privateKey, to: wallet)
            }
            .flatMap { (wallet) -> Observable<Wallet> in
                //3. create key for new account
                return walletCreateKey(wallet: wallet)
            }
            .flatMap { (wallet) -> Observable<Wallet> in
                WalletManager.shared.addWallet(wallet: wallet)
                let minCurrency = Currency(currency: "0.0001 EOS")!
                let authority = Authority(key: wallet.publicKey)
                let contract = Contract.newAccount(name: name, owner: authority, active: authority, authorization: Authorization.eoshub)
//                let buyram = Contract.buyram(payer: EOSHub.account, receiver: name, quant: minCurrency)
                let buyrambytes = Contract.buyramBytes(payer: EOSHub.account, receiver: name, bytes: 8024)
                let delegatebw = Contract.delegateBW(from: EOSHub.account, receiver: name, cpu: minCurrency, net: minCurrency)
                return RxEOSAPI.pushContract(contracts: [contract, buyrambytes, delegatebw], wallet: wallet)
                    .flatMap({ (_) -> Observable<Wallet> in
                        //account 생성시에만 wallet을 저장하게 한다.
                        return Observable.just(wallet)
                    })
            }
        
    }
    
    //MARK: get account
    static func getAccount(name: String) -> Observable<JSON> {
        return Observable.empty()
    }
    
    //MARK: transfer currency
    static func sendCurrency(from: String, to: String, quantity: Currency, memo: String = "") -> Observable<JSON> {
        
        guard let wallet = WalletManager.shared.getWallet() else { return Observable.error(EOSErrorType.walletIsNotExist)}
        
        let contract = Contract.transfer(from: from, to: to, quantity: quantity)
        
        return RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
        
    }
    //MARK: Get Currency
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
//   get_currency_stats -> abi_json_to_bin -> get_info -> get_public_keys
    
    
    
}

