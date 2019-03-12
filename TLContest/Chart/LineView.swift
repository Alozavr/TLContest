//
//  LineView.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class LineView: UIView {

    var oldPath: UIBezierPath?
    let shapeLayer = CAShapeLayer()
    var line: Line
    var coefficients: [(x: CGFloat, y: CGFloat)] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init(frame: CGRect, line: Line, coefficients: [(x: CGFloat, y: CGFloat)]) {
        self.coefficients = coefficients
        self.line = line
        super.init(frame: frame)
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapeLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext() else { return }
        shapeLayer.frame = rect
        let path = UIBezierPath()
        let lineWidth: CGFloat = 1.0
        let points = coefficients.map({ CGPoint(x: $0 * rect.width, y: rect.height - $1 * rect.height) })
        
        path.lineWidth = lineWidth
        shapeLayer.strokeColor = line.color.cgColor
        
        let startingPoint = CGPoint(x: 0, y: rect.size.height - lineWidth)
        path.move(to: startingPoint )
        for (i, _) in line.values.enumerated() {
            path.addLine(to: points[i] )
        }
        guard let previousPath = oldPath else {
            oldPath = path
            shapeLayer.path = path.cgPath
            return
        }
        CATransaction.begin()
        CATransaction.setCompletionBlock({ [weak self] in
            self?.oldPath = path
            self?.shapeLayer.path = path.cgPath
        })
        let pathAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        pathAnimation.fromValue = previousPath.cgPath
        pathAnimation.toValue = path.cgPath
        pathAnimation.duration = 0.3
        shapeLayer.add(pathAnimation, forKey:"animationKey")
        CATransaction.commit()
        
    }
 

}
