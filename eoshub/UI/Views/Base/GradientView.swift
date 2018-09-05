

import Foundation
import UIKit

class GradientView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor(white: 1, alpha: 0) {
        didSet {
            graident.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
    @IBInspectable var endColor: UIColor = UIColor(white: 0, alpha: 1.0) {
        didSet {
            graident.colors = [startColor.cgColor, endColor.cgColor]
        }
    }
    
    let graident = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        graident.frame = self.bounds
    }
    
    fileprivate func setup() {
        graident.colors = [startColor, endColor]
        graident.startPoint = CGPoint(x: 0, y: 0)
        graident.endPoint = CGPoint(x: 0, y: 1.0)
        graident.locations = [0.0, 1.0]
        graident.frame = self.bounds
        layer.insertSublayer(graident, at: 0)
    }
    
    
    
}
