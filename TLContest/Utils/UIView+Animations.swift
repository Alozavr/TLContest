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
