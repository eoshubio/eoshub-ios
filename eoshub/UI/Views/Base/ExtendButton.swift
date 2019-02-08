import Foundation
import UIKit

//iPhone 320x480 : 1 pixel = 0.15875 mm , 44 px ~ 7.0mm



class ExtendButton: UIButton {
    
    let minimumTouchPx: CGFloat = 44.0
    var touchMargin = CGSize.zero
    
    private var btnNew: UIButton?
    
    fileprivate var hasNew: Bool = false {
        didSet {
            if hasNew {
                if btnNew == nil {
                    let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
                    btn.backgroundColor = Color.red.uiColor
                    btn.layer.cornerRadius = 8
                    btn.layer.masksToBounds = true
                    btn.setTitleColor(.white, for: .normal)
                    btn.center.x = bounds.maxX - 2
                    btn.center.y = bounds.minY + 2
                    btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 9)
                    btn.isUserInteractionEnabled = false
                    addSubview(btn)
                    btnNew = btn
                }
            } else {
                btnNew?.removeFromSuperview()
            }
        }
    }
    
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
        imageView?.contentMode = .scaleAspectFit
    }
    
    func setNew(_ new: Bool, count: Int = 1) {
        hasNew = new
        btnNew?.setTitle("\(count)", for: .normal)
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

