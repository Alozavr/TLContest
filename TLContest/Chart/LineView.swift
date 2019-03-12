//
//  LineView.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class LineView: UIView {

    let line: Line
    let coefficients: [(x: CGFloat, y: CGFloat)]
    
    init(frame: CGRect, line: Line, coefficients: [(x: CGFloat, y: CGFloat)]) {
        self.coefficients = coefficients
        self.line = line
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let lineWidth: CGFloat = 1.0
        let points = coefficients.map({ CGPoint(x: $0 * rect.width, y: rect.height - $1 * rect.height) })
        
        context.setLineWidth(lineWidth)
        context.setStrokeColor(line.color.cgColor)
        let startingPoint = CGPoint(x: 0, y: rect.size.height - lineWidth)
        context.move(to: startingPoint )
        for (i, _) in line.values.enumerated() {
            context.addLine(to: points[i] )
        }
        context.strokePath()
    }
 

}
