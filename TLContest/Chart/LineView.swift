//
//  LineView.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class LineView: CAShapeLayer {

    var oldPath: UIBezierPath?
    var line: Line
    var coefficients: [(x: CGFloat, y: CGFloat)] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(layer: Any) {
        let layer = layer as! LineView
        self.line = layer.line
        self.oldPath = layer.oldPath
        self.coefficients = layer.coefficients
        super.init(layer: layer)
    }
    
    init(frame: CGRect, line: Line, coefficients: [(x: CGFloat, y: CGFloat)]) {
        self.coefficients = coefficients
        self.line = line
        super.init()
        self.frame = frame
        fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let path = UIBezierPath()
        let rect = ctx.boundingBoxOfClipPath
        let lineWidth: CGFloat = 1.0
        let points = coefficients.map({ CGPoint(x: $0 * rect.width, y: rect.height - $1 * rect.height) })
        
        path.lineWidth = lineWidth
        strokeColor = line.color.cgColor
        
        let startingPoint = CGPoint(x: 0, y: rect.size.height - lineWidth)
        path.move(to: startingPoint )
        for (i, _) in line.values.enumerated() {
            path.addLine(to: points[i] )
        }
        guard let previousPath = oldPath, oldPath != path else {
            oldPath = path
            self.path = path.cgPath
            return
        }
        CATransaction.begin()
        oldPath = path
        self.path = path.cgPath
        let pathAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
        pathAnimation.fromValue = previousPath.cgPath
        pathAnimation.toValue = path.cgPath
        pathAnimation.duration = 0.3
        pathAnimation.fillMode = .both
        add(pathAnimation, forKey:"animationKey")
        CATransaction.commit()
    }
}
