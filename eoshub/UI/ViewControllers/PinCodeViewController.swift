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
    
    enum Mode {
        case create
        case confirm(String)
        case validation
    }
    
    var mode: Mode!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar(with: .basePurple)
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
    }
    
    func configure(mode: Mode) {
        self.mode = mode
    }
    
    fileprivate func addInputView() {
        if let btnFaceId = Bundle.main.loadNibNamed("FaceIdInputView", owner: nil, options: nil)?.first as? FaceIdInputView {
            btnFaceId.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            btnFaceId.setDescription(text: LocalizedString.Secure.Pin.useFaceId)
            btnFaceId.isSelected = true //default
            pinView.addInputView(view: btnFaceId)
            
            btnFaceId.rx.tap
                .bind {
                    btnFaceId.isSelected = !btnFaceId.isSelected
                }
                .disposed(by: bag)
        }
    }
    
    fileprivate func handlePIN(pin: String) {
        switch mode! {
        case .create:
            //go To confirm
            guard let nc = navigationController, let delegate = flowDelegate as? CreatePinFlowController else { return }
            delegate.goToConfirm(from: nc, with: pin)
        case .confirm(let prvPin):
            if prvPin == pin {
                //go to wallet
            } else {
                //failed
                failAnimation()
            }
        case .validation:
            //go to previous view
            break
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
