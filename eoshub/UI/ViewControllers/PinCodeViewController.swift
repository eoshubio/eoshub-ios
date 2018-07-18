//
//  PinCodeViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class PinCodeViewController: BaseViewController {
    
    var flowDelegate: FlowEventDelegate?
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var pinView: PinCodeView!
    @IBOutlet fileprivate weak var btnClose: UIButton!
    
    enum Mode {
        case create
        case confirm(String)
        case validation
    }
    
    var mode: Mode!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        showNavigationBar(with: .basePurple)
        pinView.clear()
        pinView.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        switch mode! {
        case .create:
            lbTitle.text = LocalizedString.Secure.Pin.create
        case .confirm:
            btnClose.isHidden = true
            lbTitle.text = LocalizedString.Secure.Pin.confirm
            addInputView()
        case .validation:
            lbTitle.text = LocalizedString.Secure.Pin.validation
        }
        
        pinView.show()
    }
    
    private func bindActions() {
        pinView.filled
            .subscribe(onNext: { [weak self](pin) in
                self?.handlePIN(pin: pin)
            })
            .disposed(by: bag)
        
        btnClose.rx.singleTap
            .bind { [weak self] in
                if let delegate = self?.flowDelegate as? ValidatePinFlowDelegate {
                    guard let nc = self?.navigationController else { return }
                    delegate.cancelled(from: nc)
                }
            }
            .disposed(by: bag)
    }
    
    func configure(mode: Mode) {
        self.mode = mode
    }
    
    fileprivate func addInputView() {
        
        let type = Security.shared.biometryType()
        
        if type != .none {
            if let btnFaceId = Bundle.main.loadNibNamed("FaceIdInputView", owner: nil, options: nil)?.first as? FaceIdInputView {
                btnFaceId.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                if type == .faceID {
                    btnFaceId.setDescription(text: LocalizedString.Secure.Pin.useFaceId)
                } else {
                    btnFaceId.setDescription(text: LocalizedString.Secure.Pin.useTouchId)
                }
                btnFaceId.isSelected = true //default
                Security.shared.setEnableBioAuth(on: btnFaceId.isSelected)
                pinView.addInputView(view: btnFaceId)
                
                btnFaceId.rx.tap
                    .bind {
                        btnFaceId.isSelected = !btnFaceId.isSelected
                        Security.shared.setEnableBioAuth(on: btnFaceId.isSelected)
                        
                    }
                    .disposed(by: bag)
            }
        }
        
        
    }
    
    fileprivate func handlePIN(pin: String) {
        switch mode! {
        case .create:
            //go To confirm
            guard let nc = navigationController, let delegate = flowDelegate as? CreatePinFlowController else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                delegate.goToConfirm(from: nc, with: pin)
            }
        case .confirm(let prvPin):
            if prvPin == pin {
                //go to wallet
                //dismiss
                guard let nc = navigationController, let delegate = flowDelegate as? ConfirmFlowEventDelegate else { return }
                delegate.confirmed(from: nc)
            } else {
                //failed
                failAnimation()
            }
        case .validation:
            //go to previous view
            
            if Security.shared.validatePin(pin: pin) {
                //dismiss validation
                //go to wallet
                //dismiss
                guard let nc = navigationController, let delegate = flowDelegate as? ValidatePinFlowDelegate else { return }
                delegate.validated(from: nc)
            } else {
                failAnimation()
            }
        }
    }
    
    fileprivate func failAnimation() {
        let duration = 0.1
        UIView.animate(withDuration: duration, animations: {
            self.view.center.x = self.view.bounds.width * 0.5 + 5
        }) { (fin) in
            if fin {
                UIView.animate(withDuration: duration, animations: {
                    self.view.center.x = self.view.bounds.width * 0.5 - 5
                }, completion: { (fin) in
                    if fin {
                        UIView.animate(withDuration: duration, animations: {
                            self.view.center.x = self.view.bounds.width * 0.5
                        })
                    }
                })
            }
        }
    }
    
}

extension PinCodeViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}


