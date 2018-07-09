//
//  MultiProgressBar.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

protocol ProgressItem {
    var id: Int { get }
    var fillColor: UIColor { get }
}

protocol ProgressValue {
    var id: Int { get }
    var value: Float { get }
}

class MultiProgressBar: UIView {
    fileprivate var container: UIView!
    
    fileprivate var items: [ProgressItem] = []
    fileprivate var values: [Int: Float] = [:]
    fileprivate var views: [Int: UIView] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        container = UIView(frame: CGRect(x: 0, y: 0 , width: bounds.width, height: bounds.height))
        container.layer.cornerRadius = bounds.height * 0.5
        container.layer.masksToBounds = true
        addSubview(container)
    }
    
    private func setupProgressBar() {
        //remove previous views
        
        items.forEach { item in
            let bar = UIView(frame: CGRect(x: 0, y: 0, width:0, height: container.bounds.height))
            bar.backgroundColor = item.fillColor
            container.addSubview(bar)
            views[item.id] = bar
        }
        
    }
    
    private func relayoutProgressBar() {
        var total: Float = 0
        items.forEach { item in
            let v = values[item.id]!
            total += v
        }
        
        for i in 0..<items.count {
            let item = items[i]
            
            if let bar = views[item.id], let v = values[item.id] {
                let ratio = v / total
                let w = CGFloat(ratio) * container.bounds.width
                let x = (i == 0) ? 0 : views[item.id-1]!.frame.maxX
                bar.frame = CGRect(x: x, y: bar.bounds.minY,
                                   width: w, height: bar.bounds.height)
            }
            
        }
        
    }
    
    func configure(items: [ProgressItem]) {
        self.items = items
    
        setupProgressBar()
    }
    
    func setProgressValue(value: ProgressValue) {
        values[value.id] = value.value
        relayoutProgressBar()
    }
    
    func setProgressValues(values v: [ProgressValue]) {
        v.forEach { (value) in
            values[value.id] = value.value
        }
        relayoutProgressBar()
    }
}
