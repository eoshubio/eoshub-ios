//
//  DappWebViewController.swift
//  eoshub
//
//  Created by kein on 27/10/2018.
//  Copyright © 2018 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import WebKit

class DappWebViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    var flowDelegate: DappWebFlowEventDelegate?
    
    fileprivate var webView: WKWebView!
    
    fileprivate var dappAction: DappAction!
    
    fileprivate var selectedAccount: AccountInfo?
    
    fileprivate let transactionResult = PublishSubject<TxResult>()
    
    fileprivate var autoSignEnabled: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: false)
        addCloseButton()
    }
    
    
    
    override func loadView() {
        let webContentController = WKUserContentController()
        webContentController.add(self, name: "callbackHandler")
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = webContentController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.customUserAgent = "eoshub/" + Config.versionString
        
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = dappAction.dapp.title
        
//        WaitingView.shared.start()
        
        //check owner account
        selectAccount()
        
        bindActions()
    }
    
    private func bindActions() {
        transactionResult
            .subscribe(onNext: { [weak self] (result) in
                self?.autoSignEnabled = result.autoSign
                self?.trxConfirmed(txid: result.txid)
            }, onError: { [weak self] (error) in
                self?.trxFailed(with: error)
            })
            .disposed(by: bag)
    }
   
    func configure(dappAction: DappAction) {
        self.dappAction = dappAction
    }
    
    func reloadDappWeb(parameters: [URLQueryItem] = []) {
        
        var queryItems: [URLQueryItem] = parameters
        
        if selectedAccount != nil {
            queryItems.append(URLQueryItem(name: "account", value: selectedAccount!.account))
        }
        
        var urlComp = URLComponents(url: dappAction.dapp.url, resolvingAgainstBaseURL: true)
        urlComp?.queryItems = queryItems
        
        
        if let url = urlComp?.url {
            //        let request = URLRequest(url: defaultURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
            let request = URLRequest(url: url)
            
            webView.load(request)
            
            
        }
    }
    
    
}

extension DappWebViewController {
    

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      
        switch navigationAction.navigationType {
        case .linkActivated:
            if let url = navigationAction.request.url, let scheme = Scheme(url: url), let dappAction = DappAction(scheme: scheme) {
                configure(dappAction: dappAction)
            }
        default:
            break
        }
        
        decisionHandler(.allow)
    }
}

extension DappWebViewController {
    fileprivate func selectAccount() {
        let ownerAccountCount = AccountManager.shared.ownerInfos.count
       
        switch ownerAccountCount {
        case 0:
            showActionSheetCreateAccount()
        case 1:
            selectedAccount = AccountManager.shared.ownerInfos.first
        default:
            selectedAccount = AccountManager.shared.ownerInfos.first //default selected
            showActionSheetSelectAccount()
        }
    }
    
    fileprivate func showActionSheetCreateAccount() {
        
    }
    
    fileprivate func showActionSheetSelectAccount() {
        let alert = UIAlertController(title: LocalizedString.Dapp.Tx.selectAccount, message: LocalizedString.Dapp.Tx.selectAccountTxt, preferredStyle: .actionSheet)
        
        AccountManager.shared.ownerInfos
            .forEach { (info) in
                
                let action = UIAlertAction(title: info.account, style: .default, handler: { [weak self](_) in
                    self?.selectedAccount = info
                    //reload dapp web
                    self?.reloadDappWeb()
                })
                
                if info.account == selectedAccount?.account {
                    action.setValue(true, forKey: "checked")
                }
                
                alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: LocalizedString.Common.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func transfer(to: EOSName, quantity: Currency, memo: String) {
        
        guard let myAccount = selectedAccount, let key = myAccount.highestPriorityKey else { return }

        let auth = Authorization(actor: myAccount.account, permission: key.permission)
        
        let contract = Contract.transfer(from: myAccount.account, to: to.value, quantity: quantity, memo: memo, authorization: auth)
        
        if autoSignEnabled {
            let actor = contract.authorization.actor.value
            guard let account = AccountManager.shared.ownerInfos.filter("account = '\(actor)'").first else {
                Log.e("Cannot find valid account info")
                return
            }
            
            let indicator = UIActivityIndicatorView(style: .whiteLarge)
            view.addSubview(indicator)
            indicator.center = view.center
            indicator.startAnimating()
            
            
            guard let usingKey = account.autoSignableKey else { return }
            
            let wallet = Wallet(key: usingKey.eosioKey.key, skipAuth: true)
            
            RxEOSAPI.pushContract(contracts: [contract], wallet: wallet)
                .subscribe(onNext: { [weak self] (responseJSON) in
                    if let txid = responseJSON.string(for: "transaction_id") {
                        //response transacton id
                        self?.transactionResult.onNext(TxResult(txid: txid, autoSign: true))
                    }
                    }, onError: { [weak self] (error) in
                        self?.transactionResult.onError(error)
                        Log.e(error)
                }) {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                }
                .disposed(by: bag)
            
        } else {
            guard let nc = navigationController else { return }
            
            modalPresentationStyle = .overCurrentContext
            
            flowDelegate?.goToTxConfirm(vc: nc, contract: contract, title: dappAction.dapp.title, result: transactionResult)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        guard let selectedAccountName = selectedAccount?.account else {
            Log.i("Not logged in")
            return
        }
        
        webView.evaluateJavaScript("gb.Eoshub.loggedIn(\"\(selectedAccountName)\")") { (result, error) in
            if let error = error {
                Log.e(error)
            }
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler" {
            
            print(message.body)
            if let trx = message.body as? JSON {
               parseTrx(trx: trx)
            }
            
        }
    }
    
    fileprivate func parseTrx(trx: JSON) {
        let dapp = dappAction.dapp
        
        var hasError = true
        
        if let action = trx.string(for: "action"),
            let code = trx.string(for: "code"),
            let params = trx.json(for: "params") {
            
            if dapp.availableActions.contains(EOSName(action)) {
                if action == "transfer",
                    let to = dapp.accounts.first,
                    let quantity = params.string(for: "quantity") {
                    let amount = Currency(balance: quantity)
                    let token = Token(symbol: amount.symbol, contract: code)
                    let currency = Currency(balance: quantity, token: token)
                    let memo = params.string(for: "memo") ?? ""
                    transfer(to: to, quantity: currency, memo: memo)
                    hasError = false
                }
            }
        }
        
        if hasError {
            trxFailed(with: NetworkError.unknownAPI)
        }
        
        
    }
    
    fileprivate func trxConfirmed(txid: String) {
        
        webView.evaluateJavaScript("gb.Eoshub.trxConfirmed(\"\(txid)\")") { (result, error) in
            if let error = error {
                Log.e(error)
            }
        }
    }
    
    fileprivate func trxFailed(with error: Error) {
        webView.evaluateJavaScript("gb.Eoshub.trxFailed(\"\(error)\")") { (result, error) in
            if let error = error {
                Log.e(error)
            }
        }
        
        
    }
    
    
}
