//
//  QRScannerViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 22..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import AVFoundation
import UIKit

class QRScannerViewController: BaseViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var flowDelegate: QRScannerFlowEventDelegate?
    
    @IBOutlet fileprivate weak var qrView: RoundedView!
    @IBOutlet fileprivate weak var btnClose: UIButton!
    
    fileprivate var captureSession: AVCaptureSession!
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer!
    
    let impact = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        
        captureSession.startRunning()
    }
    
    private func setupUI() {
        qrView.layer.borderWidth = 4
        qrView.layer.borderColor = Color.lightPurple.cgColor
        qrView.setCornerRadius(radius: 5)
    
    }
    
    private func bindActions() {
        btnClose.rx.singleTap
            .bind { [weak self] in
                guard let `self` = self else { return }
                self.flowDelegate?.close(from: self)
            }
            .disposed(by: bag)
    }
    
    fileprivate func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        
        if let metadataObject = metadataObjects.first,
            metadataObject.type == .qr,
            let qrObject = previewLayer.transformedMetadataObject(for: metadataObject),
            qrView.frame.contains(qrObject.bounds) {
            
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            captureSession.stopRunning()
            impact.impactOccurred()
            found(code: stringValue)
            dismiss(animated: true)
        }
        
    }
    
    fileprivate func found(code: String) {
        print(code)
        flowDelegate?.back(from: self, qrCode: code)
    }

}
