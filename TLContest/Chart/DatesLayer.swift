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
    private var titles: [CATextLayer] = []
    private let formatter = DateFormatters()
    
    override init(layer: Any) {
        let layer = layer as! DatesLayer
        self.titles = layer.titles
//        self.formatter.dateFormat = layer.formatter.dateFormat
        self.xAxisCoefficients = layer.xAxisCoefficients
        super.init()
    }
    
    init(xAxisCoefficients: [CGFloat], dates: [Date]) {
        self.xAxisCoefficients = xAxisCoefficients
        super.init()
        for date in dates {
            titles.append(createTextLayer(with: date))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        let pointsDrawn = xAxisCoefficients
            .map({ $0 * frame.width })
    
//            .filter({ $0 + frame.origin.x >= 0 || $0 <= frame.width + frame.origin.x})
        
        for i in zip(pointsDrawn, titles) {
            i.1.frame.origin.x = i.0 - i.1.bounds.width / 2
        }
        
        guard var previousLabel = titles.first else { return }
        for label in titles.dropFirst() {
            if previousLabel.frame.intersects(label.frame) {
                if label.animation(forKey: "disapperAnimation") == nil {
                    label.animateDisappearence(removeOnComplete: false)
                }
            } else {
                if label.opacity == 0 { label.animateAppearence() }
                previousLabel = label
            }
        }
        
    }
    
    private func createTextLayer(with date: Date) -> CATextLayer {
        let size = CGSize(width: 50, height: 20)
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
//        textLayer.borderColor = UIColor.red.cgColor
//        textLayer.borderWidth = 1
        return textLayer
    }
}
