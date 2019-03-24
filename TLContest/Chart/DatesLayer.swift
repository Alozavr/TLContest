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
    private let formatter = DateFormatters.shared
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

        for (index, i) in zip(pointsDrawn, titles).enumerated() {
            if index == 0 {
                i.1.frame.origin.x = i.0 - i.1.bounds.width / 2 + 8.0 // первый чуть двигаем вперед
            } else if index == titles.count - 1 {
                i.1.frame.origin.x = i.0 - i.1.bounds.width / 2 - 8.0 // последний чуть двигаем вперед
            } else {
                i.1.frame.origin.x = i.0 - i.1.bounds.width / 2
            }
        }
        
        guard var previousLabel = titles.first else { return }
        
        previousLabel.foregroundColor = textColor
        for label in titles.dropFirst() {
            label.foregroundColor = textColor
            if previousLabel.frame.intersects(label.frame) {
                if label.opacity == 1 { label.animateDisappearence(with: 0.1, removeOnComplete: false) }
            } else {
                if label.opacity == 0 { label.animateAppearence(with: 0.1) }
                previousLabel = label
            }
        }
        
    }
    
    private func createTextLayer(with date: Date) -> CATextLayer {
        let actionsToDisableMovements = [
            "bounds": NSNull(),
            "position": NSNull()
        ]
        
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
        textLayer.actions = actionsToDisableMovements
        return textLayer
    }
}
