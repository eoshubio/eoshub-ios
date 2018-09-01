//
//  PinCodeViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 10..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import LocalAuthentication

class PinCodeViewController: BaseViewController {
    
    var flowDelegate: FlowEventDelegate?
    
    @IBOutlet fileprivate weak var lbTitle: UILabel!
    @IBOutlet fileprivate weak var logo: UIImageView!
    @IBOutlet fileprivate weak var pinView: PinCodeView!
    @IBOutlet fileprivate weak var btnClose: UIButton!
    
    @IBOutlet fileprivate weak var btn1: CircleButton!
    @IBOutlet fileprivate weak var btn2: CircleButton!
    @IBOutlet fileprivate weak var btn3: CircleButton!
    @IBOutlet fileprivate weak var btn4: CircleButton!
    @IBOutlet fileprivate weak var btn5: CircleButton!
    @IBOutlet fileprivate weak var btn6: CircleButton!
    @IBOutlet fileprivate weak var btn7: CircleButton!
    @IBOutlet fileprivate weak var btn8: CircleButton!
    @IBOutlet fileprivate weak var btn9: CircleButton!
    @IBOutlet fileprivate weak var btn0: CircleButton!
    @IBOutlet fileprivate weak var btnBio: CircleButton!
    @IBOutlet fileprivate weak var btnBack: CircleButton!
    
   
    
    private var pinButtons: [CircleButton] = []
    
    private var passcode = BehaviorRelay<String>(value: "")
    
    
    
    enum Mode {
        case create
        case confirm(String)
        case validation
        case change
    }
    
    var mode: Mode!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pinView.clear()
        pinView.show()
        
        switch mode! {
        case .confirm:
            showNavigationBar(with: .basePurple)
            addBackButton()
        default:
            break
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
    }
    
    private func setupUI() {
        
        btnBio.alpha = 0
        btnBio.isUserInteractionEnabled = false
        
        setupPinButtons()
        
        switch mode! {
        case .create:
            btnClose.isHidden = true
            lbTitle.text = LocalizedString.Secure.Pin.create
        case .confirm:
            btnClose.isHidden = true //add back
            lbTitle.text = LocalizedString.Secure.Pin.confirm
            addInputView()
        case .validation:
            lbTitle.text = LocalizedString.Secure.Pin.validation
            showBiometicIfAvailable()
            doBiometicAuthIfAvailable()
        case .change:
            lbTitle.text = LocalizedString.Secure.Pin.change
        }
        
        pinView.show()
    }
    
    private func showBiometicIfAvailable() {
        if Security.shared.enableBioAuth && Security.shared.biometryType() != .none {
            btnBio.alpha = 1.0
            btnBio.isUserInteractionEnabled = true
            
            switch Security.shared.biometryType() {
            case .faceID:
                btnBio.setImage(#imageLiteral(resourceName: "faceID"), for: .normal)
            case .touchID:
                btnBio.setImage(#imageLiteral(resourceName: "fingerprint"), for: .normal)
            case .none:
                break
            }
        }
    }
    
    private func setupPinButtons() {
        pinButtons = [btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9]
        for i in 0..<pinButtons.count {
            let btn = pinButtons[i]
            btn.tag = i
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
            btn.setThemeColor(fgColor: Color.basePurple.uiColor, bgColor: .clear , state: .normal, border: true)
        }
        btnBio.setThemeColor(fgColor: Color.ultraLightPurple.uiColor, bgColor: .clear, state: .normal, border: true)
        btnBio.imageView?.contentMode = .scaleAspectFit
        btnBio.tintColor = Color.ultraLightPurple.uiColor
        btnBack.setThemeColor(fgColor: Color.ultraLightPurple.uiColor, bgColor: .clear, state: .normal, border: true)
        btnBack.imageView?.contentMode = .scaleAspectFit
    }
    
    private func bindActions() {
        
        pinButtons.forEach { (button) in
            
            button.rx.tap
                .bind { [weak self] in
                    guard let `self` = self else { return }
                    if self.passcode.value.count < Config.maxPinCount {
                        self.passcode.accept(self.passcode.value + "\(button.tag)")
                    }
                }
                .disposed(by: bag)
        }
        
        btnBack.rx.tap
            .bind { [weak self] in
                guard let drop = self?.passcode.value.dropLast() else { return }
                self?.passcode.accept(String(drop))
            }
            .disposed(by: bag)
        
        passcode
            .bind { [weak self] (pin) in
                let count = min(pin.count, Config.maxPinCount)
                self?.pinView.changePinUI(textCount: count)
                if pin.count == Config.maxPinCount {
                    self?.handlePIN(pin: pin)
                }
            }
            .disposed(by: bag)
        
        btnBio.rx.tap
            .bind { [weak self] in
               self?.doBiometicAuthIfAvailable()
            }
            .disposed(by: bag)
        
        btnClose.rx.singleTap
            .bind { [weak self] in
                self?.handleCancel()
                
            }
            .disposed(by: bag)
    }
    
    func configure(mode: Mode) {
        self.mode = mode
    }
    
    fileprivate func handleCancel() {
        if let delegate = flowDelegate as? ValidatePinFlowDelegate {
            guard let nc = navigationController else { return }
            delegate.canceled(from: nc)
        }
        
        switch mode! {
        case .change:
            flowDelegate?.finish(viewControllerToFinish: self, animated: true, completion: nil)
        default:
            break
        }
        
    }
    
    fileprivate func doBiometicAuthIfAvailable() {
        let reason = LocalizedString.Secure.Bio.reason
        
        let lacontext = LAContext()
        if lacontext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            lacontext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    guard let nc = self?.navigationController else { return }
                    if error != nil {
                        Log.e(error!.localizedDescription)
                    } else if success {
                        //success
                        guard let delegate = self?.flowDelegate as? ValidatePinFlowDelegate else { return }
                        delegate.validated(from: nc)
                    }
                }
            }
        } else {
            EOSHubError.invalidState.showPopup()
        }
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
        case .change:
            if Security.shared.validatePin(pin: pin) {
                //dismiss validation
                //go to wallet
                //dismiss
                guard let nc = navigationController, let delegate = flowDelegate as? ChangePinFlowEventDelegate else { return }
                delegate.goToCreate(from: nc)
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

class CircleButton: RoundedButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height * 0.5
    }
}


