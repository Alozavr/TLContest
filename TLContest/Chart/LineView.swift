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
    var shouldAnimate = false
    var xCoefficients: [CGFloat] = []
    var yCoefficients: [CGFloat] = []
    var coefficients: [(x: CGFloat, y: CGFloat)] {
        return zip(xCoefficients, yCoefficients).map{ (x:$0, y:$1) }
    }
    
    var calculatedPoints: [CGPoint] = []
    var calculatedRange = ClosedRange(uncheckedBounds: (0, 0))
    
    func updatePath() {
        setNeedsDisplay()
    }
    
    override init(layer: Any) {
        let layer = layer as! LineView
        self.line = layer.line
        self.oldPath = layer.oldPath
        self.xCoefficients = layer.xCoefficients
        self.yCoefficients = layer.yCoefficients
        super.init(layer: layer)
    }
    
    init(frame: CGRect, line: Line, coefficients: [(x: CGFloat, y: CGFloat)]) {
        self.xCoefficients = coefficients.map({ $0.x })
        self.yCoefficients = coefficients.map({ $0.y })
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
        let rect = bounds
        let lineWidth: CGFloat = 1.0
        let allPoints = coefficients.map({ CGPoint(x: $0 * rect.width, y: rect.height - $1 * rect.height) })
        
        guard var indexOfPreviousPoint = allPoints.firstIndex(where: { $0.x + frame.origin.x >= 0 }) else {
            return
        }
        if indexOfPreviousPoint != 0 {
            indexOfPreviousPoint -= 1
        }
        guard let superlayer = superlayer?.superlayer, var indexOfLastVisiblePoint = allPoints.lastIndex(where: { $0.x + frame.origin.x <= superlayer.bounds.width }) else {
            return
        }
        if indexOfLastVisiblePoint != allPoints.endIndex - 1 {
            indexOfLastVisiblePoint += 1
        }
        
        self.calculatedRange = indexOfPreviousPoint...indexOfLastVisiblePoint
        let points = allPoints[calculatedRange]
        self.calculatedPoints = Array(points)
        
        path.lineWidth = lineWidth
        strokeColor = line.color.cgColor
        
        let firstPoint = points.first
        let startingPoint = CGPoint(x: firstPoint?.x ?? 0,
                                    y: firstPoint?.y ?? (rect.size.height - lineWidth))
        path.move(to: startingPoint)
        
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        
        guard let previousPath = oldPath, shouldAnimate else {
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
