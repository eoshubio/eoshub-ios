//
//  Popup.swift
//  eoshub
//
//  Created by kein on 2018. 7. 17..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class Popup: UIView {
    
    enum Style {
        case success, failed, warning
    }
    
    @IBOutlet fileprivate weak var bgView: UIView!
    @IBOutlet fileprivate weak var popup: UIView!
    @IBOutlet fileprivate weak var titleImage: UIImageView!
    @IBOutlet fileprivate weak var title: UILabel!
    @IBOutlet fileprivate weak var text: UILabel!
    @IBOutlet fileprivate weak var btnOk: UIButton!
    
    private let bag = DisposeBag()
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
  
    private func setupUI() {
        btnOk.setTitle(LocalizedString.Common.done, for: .normal)
        self.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func configure(style: Style, description: String, observer: AnyObserver<Void>? = nil) {
        
        switch style {
        case .success:
            titleImage.image = #imageLiteral(resourceName: "popupCheck")
            title.text = "Success"
        case .failed:
            titleImage.image = #imageLiteral(resourceName: "popupFail")
            title.text = "Oops..."
        case .warning:
            titleImage.image = #imageLiteral(resourceName: "popupWarning")
            title.text = "Warning..."
        }
        
        text.text = description
        
        btnOk.rx.singleTap
            .bind {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alpha = 0
                    self.popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }) { (_) in
                    observer?.onNext(())
                    observer?.onCompleted()
                    self.removeFromSuperview()
                }
            }
            .disposed(by: bag)
    }
    
    fileprivate func show() {
        let window = UIApplication.shared.keyWindow!
        frame = UIScreen.main.bounds
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
            self.popup.transform = .identity
        }
    }
    
    
    static func show(style: Style, description: String) -> Observable<Void> {
        
        guard let popup = Bundle.main.loadNibNamed("Popup", owner: nil, options: nil)?.first as? Popup else { preconditionFailure() }
        
        return Observable<Void>.create({ (observer) -> Disposable in
            
            popup.configure(style: style, description: description, observer: observer)
            
            popup.show()
            
            return Disposables.create()
        })
    }
    
    static func present(style: Style, description: String) {
        guard let popup = Bundle.main.loadNibNamed("Popup", owner: nil, options: nil)?.first as? Popup else { preconditionFailure() }
        popup.configure(style: style, description: description)
        popup.show()
    }
    
    
}
