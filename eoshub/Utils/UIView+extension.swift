//
//  RoundCornerView.swift
//  eoshub
//
//  Created by kein on 2018. 7. 8..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


extension UIView {
    
    func setCornerRadius(radius: CGFloat = 6.0) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    
}


extension UIView {
    
    func scaleToPt(_ pt: CGFloat) {
        scaleToPx(ptToPx(pt))
    }
    
    func scaleToPx(_ px: CGFloat) {
        let curWidth = self.bounds.size.width
        let toWidth = px
        let scale = toWidth / curWidth
        setScale(scale)
    }
    
    func setScale(_ scale: CGFloat) {
        self.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    func scaleAnimationLoop(startPt: CGFloat, endPt: CGFloat, duration: Double = 0.25) {
        UIView.animate(withDuration: duration, animations: {
            self.scaleToPt(startPt)
        }, completion: { (finished) in
            if finished {
                self.scaleAnimationLoop(startPt: endPt, endPt: startPt)
            } else {
                print("animation stopped")
            }
            
        })
    }
    
    func bounceAnimation(startScale: CGFloat = 1.2) -> Observable<Bool> {
        removeAllAnimations()
        setScale(startScale)
        return scaleAnimation(to: 0.9, duration: 0.1)
//            .flatMap {_ in
//                return self.scaleAnimation(to: 1.05, duration: 0.1)
//            }
//            .flatMap { _ in
//                return self.scaleAnimation(to: 0.95, duration: 0.15)
//            }
            .flatMap { _ in
                return self.scaleAnimation(to: 1.0, duration: 0.15)
        }
    }
    
    func bounceUpAnimation() -> Observable<Bool> {
        removeAllAnimations()
        setScale(0.1)
        
        return scaleAnimation(to: 1.2, duration: 0.15)
            .flatMap {_ in
                return self.scaleAnimation(to: 1.0, duration: 0.1)
            }
            .flatMap { _ in
                return self.scaleAnimation(to: 1.05, duration: 0.15)
            }
            .flatMap { _ in
                return self.scaleAnimation(to: 1.0, duration: 0.15)
        }
    }
    
    func bounceDownAnimation() -> Observable<Bool> {
        removeAllAnimations()
        return scaleAnimation(to: 1.2, duration: 0.2)
            .flatMap {_ in
                return self.scaleAnimation(to: 0.1, duration: 0.15)
        }
    }
    
    
    func scaleAnimation(to scale: CGFloat, duration: TimeInterval) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            
            UIView.animate(withDuration: duration, animations: {
                self.setScale(scale)
            }, completion: { (finished) in
                observer.onNext(finished)
                observer.onCompleted()
            })
            
            return Disposables.create {
                
            }
            
        })
    }
    
    
    
    func blinkAnimationLoop(startAlpha: CGFloat, endAlpha: CGFloat, duration: Double = 0.25) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = startAlpha
        }, completion: { (finished) in
            if finished {
                self.blinkAnimationLoop(startAlpha: endAlpha, endAlpha: startAlpha, duration: duration)
            } else {
                print("animation stopped")
            }
        })
    }
    
    func showWithDelayAndTransform (_ delay: Double, startTransform: CGAffineTransform, endTransform: CGAffineTransform, completion: (()->Void)? = nil ) {
        removeAllAnimations()
        self.transform = startTransform
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1.0
            self.transform = endTransform
        }, completion: { (finished) in
            if finished {
                UIView.animate(withDuration: 0.2, delay: delay, options: UIViewAnimationOptions(), animations: {
                    self.alpha = 0
                    self.transform = startTransform
                }, completion: { (finished) in
                    if finished { completion?() }
                })
            }
        })
        
    }
    
    func removeAllAnimations() {
        self.layer.removeAllAnimations()
    }
    
    func hasAnimation() -> Bool {
        if let animationCount = layer.animationKeys()?.count, animationCount > 0 {
            return true
        }
        return false
    }
    
}


extension UIView {
    func getConstraint(attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        return constraints.filter { (constraint) -> Bool in
            let firstMatch = (constraint.firstItem as? NSObject == self && constraint.firstAttribute == attribute)
            let secondMatch = (constraint.secondItem as? NSObject == self && constraint.secondAttribute == attribute)
            return firstMatch || secondMatch
            }.last
    }
}
