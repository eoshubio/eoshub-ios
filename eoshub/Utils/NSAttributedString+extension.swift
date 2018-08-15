//
//  NSAttributedString+extension.swift
//  eoshub
//
//  Created by kein on 2018. 8. 6..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func addAttributeColor(text: String, color: UIColor) {
        addAttribute(text: text, attr: [NSAttributedStringKey.foregroundColor : color])
    }
    
    func addAttributeURL(text: String, url: URL) {
        addAttribute(text: text, attr: [NSAttributedStringKey.link : url])
    }
    
    func addAttributeFont(text: String, font: UIFont) {
        addAttribute(text: text, attr: [NSAttributedStringKey.font : font])
    }
    
    func addLineHeight(height: CGFloat) {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = height
        addAttribute(text: string, attr: [NSAttributedStringKey.paragraphStyle: style])
    }
    
    private func addAttribute(text: String, attr: [NSAttributedStringKey: Any]) {
        if let range = string.range(of: text) {
            addAttributes(attr, range: range.nsRange)
        }
    }
    
}
