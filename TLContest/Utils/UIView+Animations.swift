//
//  UIView+Animations.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

extension UIView {
    func animateAppearence(with duration: TimeInterval = 0.3) {
        self.alpha = 0
        UIView.animate(withDuration: duration) { [weak self] in
            self?.alpha = 1
        }
    }
    
    func animateDisappearence(with duration: TimeInterval = 0.3, removeOnComplete: Bool) {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.alpha = 0
            }) { [weak self] _ in
                if removeOnComplete { self?.removeFromSuperview() }
        }
    }
}

extension CALayer {
    func animateAppearence(with duration: TimeInterval = 0.3) {
        self.opacity = 1
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = duration
        self.add(animation, forKey: "appearAnimation")
    }
    
    func animateDisappearence(with duration: TimeInterval = 0.3, removeOnComplete: Bool) {
        guard opacity != 0 else { return }
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            if removeOnComplete {
                self?.removeFromSuperlayer()
            }
        }
        self.opacity = 0
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.0
        animation.duration = duration
        self.add(animation, forKey: "disapperAnimation")
        CATransaction.commit()
    }
}
