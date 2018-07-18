//
//  TouchIdViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 18..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication

class TouchIdViewController: BaseViewController {
    
    var flowDelegate: ValidatePinFlowDelegate?
    
    @IBOutlet fileprivate weak var guide: UILabel!
    @IBOutlet fileprivate weak var icon: UIImageView!
    @IBOutlet fileprivate weak var type: UILabel!
    @IBOutlet fileprivate weak var btnClose: UIButton!
    
   
    
    enum AuthMode {
        case touch, face
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    
    private func setupUI() {
        switch Security.shared.biometryType() {
        case .faceID:
            configure(mode: .face)
        case .touchID:
            configure(mode: .touch)
        case .none:
            break
        }
        
        let reason = LocalizedString.Secure.Bio.reason
        
        let lacontext = LAContext()
        if lacontext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            lacontext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    guard let nc = self?.navigationController else { return }
                    if error != nil {
                        Popup.present(style: Popup.Style.failed, description: error!.localizedDescription)
                        
                    } else if success {
                        //success
                        self?.flowDelegate?.validated(from: nc)
                        
                    } else {
                        //false
                        self?.flowDelegate?.cancelled(from: nc)
                        Log.e("false")
                    }
                }
            }
        } else {
            //fail
            guard let nc = navigationController else { return }
            flowDelegate?.cancelled(from: nc)
            Log.e("invalid state")
        }
    }
    
    fileprivate func configure(mode: AuthMode) {
        if mode == .face {
            guide.text = LocalizedString.Secure.Bio.faceID
            icon.image = #imageLiteral(resourceName: "faceID")
            type.text = "Face ID"
        } else if mode == .touch {
            guide.text = LocalizedString.Secure.Bio.touchID
            icon.image = #imageLiteral(resourceName: "touchID")
            type.text = "Touch ID"
        }
    }
    
    private func bindActions() {
        btnClose.rx.singleTap
            .bind { [weak self] in
                guard let nc = self?.navigationController else { return }
                self?.flowDelegate?.finish(viewControllerToFinish: nc, animated: true, completion: nil)
            }
            .disposed(by: bag)
    }
    
}


extension TouchIdViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
