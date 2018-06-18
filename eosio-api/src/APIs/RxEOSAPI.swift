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
    static func pushContract(contract: Contract, wallet: Wallet) -> Observable<JSON> {
        
        //1. unlock wallet
        return RxEOSAPI.walletUnlock(array: wallet.paramter)
            .flatMap { (open) -> Observable<BinaryString> in
                //2. json to bin
                return RxEOSAPI.jsonToBin(json: contract.json)
            }
            .flatMap { (binary) -> Observable<(BlockInfo, Action)> in
                //2. get block info
                return RxEOSAPI.getInfo()
                    .flatMap({ (blockInfo) -> Observable<(BlockInfo, Action)> in
                        let action = Action(account: contract.code, name: contract.action, authorization: contract.authorization, data: binary.bin)
                        return Observable.just((blockInfo, action))
                    })
            }
            .flatMap { (data) -> Observable<(BlockInfo, Action, Block)> in
                //3. get block
                return RxEOSAPI.getBlock(json: ["block_num_or_id": data.0.headBlockNum])
                    .flatMap({ (block) -> Observable<(BlockInfo, Action, Block)> in
                        return Observable.just((data.0, data.1, block))
                    })
            }
            .flatMap({ (data) -> Observable<(BlockInfo, Action, Block, [String])> in
                //4. get requried keys
                let trx = Transaction(block: data.2, actions: [data.1])
                var input: JSON = [:]
                input["available_keys"] = WalletManager.shared.getKeys()
                input["transaction"] = trx.json
                return RxEOSAPI.getRequiredKeys(json: input)
                    .flatMap({ (response) -> Observable<(BlockInfo, Action, Block, [String])> in
                        let keys = response["required_keys"] as? [String] ?? [EOSIO.publicKey]
                        return Observable.just((data.0, data.1, data.2, keys))
                    })
            })
            .flatMap { (data) -> Observable<JSON> in
                //5. sign transaction
                let trx = Transaction(block: data.2, actions: [data.1]).json
                let input: [Any] = [trx, data.3, data.0.chainId] //transaction, keys, chainid
                print(input)
                return RxEOSAPI.signTransaction(array: input)
            }
            .flatMap { (json) -> Observable<JSON> in
                //6. push transaction
                guard let input = SignedTransaction(json: json) else { return Observable.error(EOSErrorType.invalidFormat) }
                print(input)
                return RxEOSAPI.pushTransaction(json: input.json)
        }
        
    }
    
    
}


extension RxEOSAPI {
    static func createAccount(name: String, authorization: Authorization) -> Observable<JSON> {
        //1. create wallet
        
        return walletCreate(name: name)
            .flatMap { (wallet) -> Observable<Wallet> in
                //2. import eosio key
                return walletImportKey(key: EOSIO.privateKey, to: wallet)
            }
            .flatMap { (wallet) -> Observable<Wallet> in
                //3. create key for new account
                return walletCreateKey(wallet: wallet)
            }
            .flatMap { (wallet) -> Observable<JSON> in
                
                let authority = Authority(key: wallet.publicKey)
                let contract = Contract.newAccount(name: name, owner: authority, active: authority, authorization: Authorization.eosio)
                return RxEOSAPI.pushContract(contract: contract, wallet: wallet)
                    .flatMap({ (json) -> Observable<JSON> in
                        //account 생성시에만 wallet을 저장하게 한다.
                        WalletManager.shared.addWallet(wallet: wallet)
                        return Observable.just(json)
                    })
            }
    }
    
    static func sendCurrency(from: String, to: String, quantity: Currency, memo: String = "") -> Observable<JSON> {
        
        guard let wallet = WalletManager.shared.getWallet() else { return Observable.error(EOSErrorType.walletIsNotExist)}
        
        let contract = Contract.transfer(from: from, to: to, quantity: quantity)
        
        return RxEOSAPI.pushContract(contract: contract, wallet: wallet)
        
    }
    
    static func getCurrencyBalance(name: String, symbol: String) -> Observable<[Currency]> {
//        curl http://175.195.57.102:8888/v1/chain/get_currency_balance -d '{"account": "eoshub", "code": "eosio.token", "symbol": "EOS"}'
        let input = ["account": name, "symbol": symbol, "code": "eosio.token"]
        return EOSAPI.Chain.get_currency_balance
                .responseArray(method: .post, parameter: input, encoding: JSONEncoding.default)
                .flatMap { (result) -> Observable<[Currency]> in
                    let currency = result.compactMap { $0 as? String }.compactMap(Currency.init)
                    return Observable.just(currency)
                }
        }
}

