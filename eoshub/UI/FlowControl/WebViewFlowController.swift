//
//  WebViewFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 8. 20..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class WebViewFlowController: FlowController {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .web }
    
    var urlString: String!
    var title: String?
    
    required init(configure: FlowConfigure) {
        self.configure = configure
    }
    
    func configure(urlString: String, title: String?) {
        self.urlString = urlString
        self.title = title
    }

    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else { return }
        vc.configure(urlString: urlString, title: title)
        show(viewController: vc, animated: animated) {
            
        }
    }
}

