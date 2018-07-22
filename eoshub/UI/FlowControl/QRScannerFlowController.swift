//
//  QRScannerFlowController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 22..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class QRScannerFlowController: FlowController, QRScannerFlowEventDelegate {
    var configure: FlowConfigure
    
    var id: FlowIdentifier { return .qrcode }
    
    var resultQRCode = PublishSubject<String?>()

    required init(configure: FlowConfigure) {
        self.configure = configure
    }

    
    func show(animated: Bool) {
        
        guard let vc = UIStoryboard(name: "Wallet", bundle: nil).instantiateViewController(withIdentifier: "QRScannerViewController") as? QRScannerViewController else { return }
        vc.flowDelegate = self
        show(viewController: vc, animated: animated) {
            
        }
    }
    
    func back(from vc: UIViewController, qrCode: String) {
        Log.i(qrCode)
        resultQRCode.onNext(qrCode)
        finish(viewControllerToFinish: vc, animated: true, completion: nil)
    }
    
    func close(from vc: UIViewController) {
        resultQRCode.onNext(nil)
        finish(viewControllerToFinish: vc, animated: true, completion: nil)
    }
}

protocol QRScannerFlowEventDelegate: FlowEventDelegate {
    func back(from: UIViewController, qrCode: String)
    func close(from: UIViewController)
}


