//
//  HeightAnimator.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 22/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

protocol HeightAnimatorDelegate: class {
    func needsRedraw(currentHeight: CGFloat)
}

internal struct Easings {
    
    static let easeInQuad =  { (t:Double) -> Double in  return t*t; }
    static let easeOutQuad = { (t:Double) -> Double in  return 1 - Easings.easeInQuad(1-t); }
}


class HeightAnimator {
    
    var currentValue: CGFloat
    var startValue: CGFloat
    var endValue: CGFloat
    var isAnimating: Bool = false
    weak var delegate: HeightAnimatorDelegate?
    var displayLink: CADisplayLink!
    let easingFunction: (Double) -> CGFloat = { t in return CGFloat(Easings.easeOutQuad(t)) }
    var previousTimestamp: TimeInterval = 0
    let animationDuration: Double = 3
    var elapsedTime = 0.0

    typealias Animation = (startPoint: CGFloat, endPoint: CGFloat)
    var animations: [Animation] = []
    
    init(startValue: CGFloat, endValue: CGFloat, delegate: HeightAnimatorDelegate) {
        self.startValue = startValue
        self.endValue = endValue
        self.delegate = delegate
        currentValue = startValue
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(displayRefreshed))
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.main, forMode: .default)
    }
    
    func startAnimation(startValue: CGFloat, endValue: CGFloat) {
        if startValue == endValue { return }
        
        let animation = (startPoint: startValue, endPoint: endValue)
        if !isAnimating {
            self.startValue = animation.startPoint
            currentValue = startValue
        }
        self.endValue = animation.endPoint
        isAnimating = true
        previousTimestamp = 0
        elapsedTime = 0
        displayLink.isPaused = false
    }
    
    @objc func displayRefreshed() {
        if !isAnimating { return }
        if previousTimestamp == 0 {
            previousTimestamp = displayLink.timestamp
            return
        }
        
        let dt = displayLink.timestamp - previousTimestamp
        elapsedTime += dt
        if elapsedTime >= animationDuration {
            delegate?.needsRedraw(currentHeight: endValue)
            stopAnimation()
            return
        }
        
        let diff = endValue - startValue
        
        currentValue = startValue + diff * easingFunction(elapsedTime/animationDuration)
        if diff > 0 ? currentValue > endValue : currentValue < endValue {
            delegate?.needsRedraw(currentHeight: endValue)
            stopAnimation()
            return
        }
        delegate?.needsRedraw(currentHeight: currentValue)
    }
    
    private func stopAnimation() {
        displayLink.isPaused = true
        isAnimating = false
        previousTimestamp = 0
        elapsedTime = 0
    }
    
    
}
