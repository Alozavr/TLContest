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
    private let textColor = UIColor(hexString: "cbd3dd").cgColor
    
    override init(layer: Any) {
        let layer = layer as! DatesLayer
        self.titles = layer.titles
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
        
        for i in zip(pointsDrawn, titles) {
            i.1.frame.origin.x = i.0 - i.1.bounds.width / 2
        }
        
        guard var previousLabel = titles.first else { return }
        
        guard let superView = superlayer?.delegate as? DetailedChartView else { return } // TODO: Delete me
        let visibleTitles = Array(titles[superView.currentRange]) // TODO: Delete me
        let alwaysShownLabelsAtIndexes = [(visibleTitles.count - 1) / 4, 3 * (visibleTitles.count - 1) / 4, (visibleTitles.count - 1) / 2] // TODO: Delete me
        
        previousLabel.foregroundColor = textColor
        for (index, label) in titles.dropFirst().enumerated() {
            label.foregroundColor = textColor
            
            // TODO: Delete me
//            if superView.currentRange.contains(index),
//                let visibleItemIndex = visibleTitles.index(ofElement: label),
//                alwaysShownLabelsAtIndexes.contains(visibleItemIndex) {
//                label.opacity = 1
//
//                if previousLabel.frame.intersects(label.frame) {
//                    if previousLabel.animation(forKey: "disapperAnimation") == nil {
//                        previousLabel.opacity = 0
//                    }
//                }
//                previousLabel = label
//                continue
//            }
            
            if previousLabel.frame.intersects(label.frame) {
                if label.animation(forKey: "disapperAnimation") == nil {
                    label.animateDisappearence(with: 0.15, removeOnComplete: false)
                }
            } else {
                if label.opacity == 0 { label.animateAppearence(with: 0.15) }
                previousLabel = label
            }
        }
        
    }
    
    private func createTextLayer(with date: Date) -> CATextLayer {
        let size = CGSize(width: 60, height: 20)
        let textLayer = CATextLayer()
        let string = formatter.format(date: date)
        let font = UIFont.systemFont(ofSize: 12)
        addSublayer(textLayer)
        textLayer.font = CTFontCreateWithName(font.fontName as CFString, 0, nil)
        textLayer.foregroundColor = textColor
        textLayer.bounds.size = size
        textLayer.frame = CGRect(origin: CGPoint.zero, size: size)
        textLayer.alignmentMode = .center
        textLayer.fontSize = 12
        textLayer.string = string
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
}
