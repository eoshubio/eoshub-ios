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

class DappWebViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {
    var flowDelegate: DappWebFlowEventDelegate?
    
    fileprivate var webView: WKWebView!
    
    fileprivate var dappAction: DappAction!
    
    fileprivate var selectedAccount: AccountInfo?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: false)
        addCloseButton()
    }
    
    
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = dappAction.dapp.title
        
//        WaitingView.shared.start()
        
        //check owner account
        selectAccount()
    }
    
   
    func configure(dappAction: DappAction) {
        self.dappAction = dappAction
    
        handleAction()
    }
    
    func reloadDappWeb() {
        var urlString = dappAction.dapp.url.absoluteString
        if selectedAccount != nil {
            urlString += "?account=" + selectedAccount!.account
        }
        
        if let url = URL(string: urlString) {
            //        let request = URLRequest(url: defaultURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
            let request = URLRequest(url: url)
            
            webView.load(request)
        }
    }
    
    
}

extension DappWebViewController {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        WaitingView.shared.stop()
    }

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
            reloadDappWeb()
            showActionSheetCreateAccount()
        case 1:
            selectedAccount = AccountManager.shared.ownerInfos.first
            reloadDappWeb()
        default:
            reloadDappWeb()
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
    
    fileprivate func handleAction() {
        
        switch dappAction.action {
        case .transfer(let to, let quantity):
            transfer(to: to, quantity: quantity)
        case .login:
            selectAccount()
        case .logout:
            selectedAccount = nil
            reloadDappWeb()
        default:
            Log.e("invalid request")
            break
        }
    }
    
    fileprivate func transfer(to: EOSName, quantity: Currency) {
        
        guard let myAccount = selectedAccount, let key = myAccount.highestPriorityKey else { return }

        let auth = Authorization(actor: myAccount.account, permission: key.permission)
        
        let contract = Contract.transfer(from: myAccount.account, to: to.value, quantity: quantity, authorization: auth)
        
        guard let nc = navigationController else { return }
        
        modalPresentationStyle = .overCurrentContext
        
        flowDelegate?.goToTxConfirm(vc: nc, contract: contract, title: dappAction.dapp.title)
        
    }
}
