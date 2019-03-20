//
//  InfoLineView.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 20/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class InfoLineView: CAShapeLayer {
    
    var title: String = ""
    var max: CGFloat = 0.0
    
    let linesCount = 5
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    init(frame: CGRect, title: String, max: CGFloat) {
        self.title = title
        self.max = max
        super.init()
        self.frame = frame
        fillColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let rect = ctx.boundingBoxOfClipPath
        
        let yLabelInterval = max / CGFloat(linesCount)
        
        let labelHeight: CGFloat = 20.0
        let inset: CGFloat = 8.0
        let labelFrame = CGRect(x: inset,
                                y: labelHeight,
                                width: 40,
                                height: labelHeight)
        
        let title = String(format: "%d", yLabelInterval)
        let textLayer = CATextLayer()
        textLayer.frame = labelFrame
        textLayer.foregroundColor = Colors.shared.textColor.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = .left
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(UIFont.systemFont(ofSize: 12).fontName as CFString, 0, nil)
        textLayer.fontSize = 12.0
        textLayer.string = title
        
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: inset,
                                  y: 0))
        linePath.addLine(to: CGPoint(x: rect.width,
                                     y: 0))
        lineWidth = 1.0
        strokeColor = Colors.shared.secondaryAColor.cgColor
        
        self.path = linePath.cgPath
    }
}
