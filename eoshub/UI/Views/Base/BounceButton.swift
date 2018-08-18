
import Foundation
import UIKit
import RxSwift

class BounceButton: UIButton {
    
    
    private var isScaleUp: Bool = false
    private let bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTargets()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTargets()
    }
    
    private func setupTargets() {
        adjustsImageWhenHighlighted = false
        
        addTarget(self, action: #selector(self.scaleUp), for: .touchDown)
        addTarget(self, action: #selector(self.scaleDownWithBounce), for: .touchUpInside)
        addTarget(self, action: #selector(self.scaleDownWithBounce), for: .touchUpOutside)
        addTarget(self, action: #selector(self.scaleDownWithBounce), for: .touchCancel)
    }
    
    
    @objc private func scaleUp() {
        if isScaleUp == false {
            isScaleUp = true
            UIView.animate(withDuration: 0.15, animations: {
                self.setScale(1.1)
            })
        }
        
        
    }
    
    @objc private func scaleDownWithBounce() {
        if isScaleUp {
            isScaleUp = false
            bounceAnimation(startScale: 1.1)
                .subscribe()
                .disposed(by: bag)
        }
    }
    
    
}
