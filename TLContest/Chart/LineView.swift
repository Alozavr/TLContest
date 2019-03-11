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
    
    init(frame: CGRect, line: Line) {
        self.line = line
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let lineWidth: CGFloat = 1.0
        context.setLineWidth(lineWidth)
        context.setStrokeColor(line.color.cgColor)
        let startingPoint = CGPoint(x: 0, y: rect.size.height - lineWidth)
        let endingPoint = CGPoint(x: rect.size.width, y: rect.size.height - lineWidth)
        context.move(to: startingPoint )
        context.addLine(to: endingPoint )
        context.strokePath()
    }
 

}
