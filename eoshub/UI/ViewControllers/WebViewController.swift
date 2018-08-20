//
//  WebViewController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import WebKit

class WebViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {
    fileprivate var webView: WKWebView!
    
    fileprivate var urlString: String!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple, animated: animated, largeTitle: true)
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
        
        WaitingView.shared.start()
        
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    
    
    func configure(urlString: String, title: String?) {
        self.urlString = urlString
        self.title = title
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        WaitingView.shared.stop()
    }
}
