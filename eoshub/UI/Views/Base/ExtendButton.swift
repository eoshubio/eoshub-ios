import Foundation
import UIKit

//iPhone 320x480 : 1 pixel = 0.15875 mm , 44 px ~ 7.0mm



class ExtendButton: UIButton {
    
    let minimumTouchPx: CGFloat = 44.0
    var touchMargin = CGSize.zero
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        setupMargin()
    }
    
    func setupMargin() {
        if touchMargin == .zero {
            let minTouchArea = CGSize(width: minimumTouchPx, height: minimumTouchPx)
            
            if bounds.contains(CGRect(x: 0, y: 0, width: minTouchArea.width, height: minTouchArea.height)) == false {
                touchMargin = (minTouchArea - bounds.size) * 0.5
            }
        }
    }
    
    
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        let touchArea = bounds.insetBy(dx: -touchMargin.width, dy: -touchMargin.height)
        
        if touchArea.contains(point) {
            return self
        } else {
            return super.hitTest(point, with: event)
        }
    }
}

