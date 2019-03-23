//
//  DatesLayer.swift
//  TLContest
//
//  Created by Dmitry grebenshchikov on 23/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class DatesLayer: CALayer {
    
    var xAxisCoefficients: [CGFloat]
    private var titles: [Date: CATextLayer] = [:]
    private let formatter = DateFormatters()
    
    override init(layer: Any) {
        let layer = layer as! DatesLayer
        self.titles = layer.titles
//        self.formatter = layer.formatter
        self.xAxisCoefficients = layer.xAxisCoefficients
        super.init()
    }
    
    init(xAxisCoefficients: [CGFloat], dates: [Date]) {
        self.xAxisCoefficients = xAxisCoefficients
        super.init()
        backgroundColor = UIColor.green.cgColor
        for date in dates {
            titles[date] = createTextLayer(with: date)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        if let first = titles.values.first, first.bounds.height != bounds.height {
            for title in titles.values {
                title.bounds.size.height = bounds.height
            }
        }
        
        let pointsDrawn = xAxisCoefficients
            .map({ $0 * frame.width })
    
//            .filter({ $0 + frame.origin.x >= 0 || $0 <= frame.width + frame.origin.x})
        
        for i in zip(pointsDrawn, titles.values) {
            i.1.frame.origin.x = i.0
        }
    }
    
    private func createTextLayer(with date: Date) -> CATextLayer {
        let size = CGSize(width: 80, height: 20)
        let textLayer = CATextLayer()
        let string = formatter.format(date: date)
        let font = UIFont.systemFont(ofSize: 14)
        addSublayer(textLayer)
        textLayer.font = CTFontCreateWithName(font.fontName as CFString, 0, nil)
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.bounds.size = size
        textLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        textLayer.alignmentMode = .center
        textLayer.fontSize = 14
        textLayer.string = string
        return textLayer
    }
}
