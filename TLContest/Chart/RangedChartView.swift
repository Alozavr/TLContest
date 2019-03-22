//
//  RangedChartView.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 13/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class RangedChartView: UIControl, HeightAnimatorDelegate {
    
    var xAxisCoefficients: [CGFloat] = []
    
    var dateAxis: [Date] = []
    var visibleLines: [Line] = []
    var lineCoefficients: [Int: [CGFloat]] = [:]
    var currentRange = ClosedRange<Int>(uncheckedBounds: (0, 0))
    
    var animator: HeightAnimator!
    
    var previousMax: CGFloat = 0.0
    var previousMax2: CGFloat = 0.0
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        animator = HeightAnimator(startValue: 0, endValue: 0, delegate: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        animator = HeightAnimator(startValue: 0, endValue: 0, delegate: self)
    }
    
    func needsRedraw(currentHeight: CGFloat) {
        redrawLines(maxHeight: currentHeight)
    }
    
    func redrawLines(maxHeight: CGFloat) {
        let min: CGFloat = 0
        
        for (index, line) in visibleLines.enumerated() {
            let lineCoefficients = line.values.map({ (CGFloat($0) - min) / (maxHeight - min) })
            self.lineCoefficients[index] = lineCoefficients
            guard lineCoefficients.count == xAxisCoefficients.count else { continue }
            guard let view = layer.sublayers?.compactMap({ $0 as? LineView }).first(where: { $0.line.id == line.id }) else {
                continue
            }
            if view.opacity == 0 { view.animateAppearence() }
            view.yCoefficients = lineCoefficients
            view.updatePath()
        }
    }
    
    func displayChart(chart: Chart, yRange: ClosedRange<Int>) {
        currentRange = yRange
        
        if chart.dateAxis != dateAxis {
            xAxisCoefficients.removeAll()
        }
        
        self.dateAxis = chart.dateAxis
        calculateXAxisCoefficients(chart)
        
        let viewsToRemove = layer.sublayers?.compactMap { (subView) -> LineView? in
            guard let lineView = subView as? LineView else { return nil }
            guard let line = chart.lines.first(where: { $0.id == lineView.line.id }) else {
                return nil
            }
            lineView.line = line
            return !line.isVisible ? lineView : nil
            } ?? []
        
        for view in viewsToRemove {
            view.animateDisappearence(removeOnComplete: false)
        }
        
        let lines = chart.lines.filter { $0.isVisible }
        let willAnimate = lines.count != visibleLines.count
        self.visibleLines = lines
        guard let tempMax = lines.compactMap({ $0.values[yRange].max() }).max()/*, let min = joinedYValues.min()*/ else { return }
        var max = CGFloat(tempMax)
                
        if max != previousMax2 && previousMax2 != 0 {
            animator.startAnimation(startValue: previousMax2, endValue: max)
            previousMax2 = max
            return
        }
        previousMax2 = max
        if animator.isAnimating { max = animator.currentValue }
        let min: CGFloat = 0
        
        for (index, line) in lines.enumerated() {
            let lineCoefficients = line.values.map({ (CGFloat($0) - min) / (max - min) })
            self.lineCoefficients[index] = lineCoefficients
            guard lineCoefficients.count == xAxisCoefficients.count else { continue }
            let coefficients = zip(xAxisCoefficients, lineCoefficients).map({ (x:$0, y:$1) })
            guard let view = layer.sublayers?.compactMap({ $0 as? LineView }).first(where: { $0.line.id == line.id }) else {
                createLineView(line: line, coefficients: coefficients)
                continue
            }
            view.shouldAnimate = willAnimate
            if view.opacity == 0 { view.animateAppearence() }
            
            view.xCoefficients = xAxisCoefficients
            view.updatePath()
            
            
            // MARK: - Create Date Labels
            
            removeTempLayers(inArray: tempXAxisLayers)
            tempXAxisLayers.removeAll()
            
            let calculatedPoints: [CGPoint] = Array(view.calculatedPoints
                .map({ CGPoint(x: $0.x + view.frame.origin.x, y: $0.y) })
                .filter({ $0.x >= 0.0 && $0.x <= view.frame.width - view.frame.origin.x }).dropLast())
            
            let points = Array(calculatedPoints)
            
            var neededElements: [CGPoint] = []
            
            for (index, point) in points.enumerated() {
                if index % 4 == 0 {
                    neededElements.append(point)
                } else if index == points.count - 1 {
                    neededElements.append(point)
                } else if index == points.count / 2 {
                    neededElements.append(point)
                } else if index == 0 {
                    neededElements.append(point)
                }
            }
            
            var datesAxis = dateAxis
            
            if yRange.upperBound - yRange.lowerBound + 1 >= points.count {
                datesAxis = Array(dateAxis[yRange])
            }
            
            var textXLayers: [CALayer] = []
            
            let neededElementsFittedScreen = neededElements.filter({ $0.x < bounds.width })
            
            let maximumFittedElementsOnScreen = 5
            
            if neededElementsFittedScreen.count <= maximumFittedElementsOnScreen, points.count <= 16 {
                neededElements = points
            }
            
            for point in neededElementsFittedScreen {
                guard let pointIndex = points.index(ofElement: point) else {
                    continue
                }
                // рисуем лейблы
                let date = datesAxis[pointIndex]
                let width: CGFloat = 60
                let height: CGFloat = 20
                let title = dateFormatters.format(date: date)
                let labelFrame = CGRect(x: point.x - width / 2.0,
                                        y: bounds.height - height,
                                        width: width,
                                        height: height)
                
                let xLabel = getLabelLayer(title: title,
                                                     frame: labelFrame,
                                                     font: .systemFont(ofSize: 12.0),
                                                     color: UIColor(hexString: "cbd3dd"),
                                                     alignment: .center)
            
                textXLayers.append(xLabel)
                layer.addSublayer(xLabel)
                tempXAxisLayers.append(xLabel)
            }
        }
        
    }
    
    private var tempXAxisLayers: [CALayer] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let sublayers = layer.sublayers else { return }
        for layer in sublayers {
            guard layer.frame.isEmpty else { continue }
            layer.frame = self.bounds
            layer.setNeedsDisplay()
        }
    }
    
    private func createLineView(line: Line, coefficients: [(x: CGFloat, y: CGFloat)]) {
        let lineView = LineView(frame: self.bounds, line: line, coefficients: coefficients)
        layer.addSublayer(lineView)
        lineView.animateAppearence()
    }
    
    private func calculateXAxisCoefficients(_ chart: Chart) {
        guard xAxisCoefficients.isEmpty,
            let lastDate = chart.dateAxis.last?.timeIntervalSince1970,
            let firstDate = chart.dateAxis.first?.timeIntervalSince1970 else { return }
        xAxisCoefficients = chart.dateAxis.map({ CGFloat( ($0.timeIntervalSince1970 - firstDate) / (lastDate - firstDate)) })
    }
    
    // MARK: - Touches
    
    private var previousLocation = CGPoint()
    private var tempLayers: [CALayer] = []
    private let impact = UIImpactFeedbackGenerator(style: .light)
    private var previousX: CGFloat = 0.0
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        return true
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        previousLocation = location
        
        let characteristicSize: CGFloat = bounds.width / CGFloat(currentRange.upperBound - currentRange.lowerBound + 1)
        let delta: CGFloat = characteristicSize
        
        guard let view = layer.sublayers?
            .compactMap({ $0 as? LineView })
            .first(where: { $0.line.id == visibleLines.first?.id }) else {
                return true
        }
        
        let calculatedPoints: [CGPoint] = view.calculatedPoints
            .map({ CGPoint(x: $0.x + view.frame.origin.x, y: $0.y) })
            .filter({ $0.x >= 0.0 && $0.x <= view.frame.width - view.frame.origin.x })
        
        guard let coeffIndex = calculatedPoints.index(where: { $0.x > location.x - delta && $0.x < location.x + delta }) else {
            return true
        }
        
        let correctRange = ClosedRange(uncheckedBounds: (max(currentRange.lowerBound, 0),
                                                         max(currentRange.upperBound, coeffIndex)))
        
        let x = calculatedPoints[coeffIndex].x
        
        removeTempInfoLayers()
        
        if previousX != x {
            impact.impactOccurred()
        }
        
        previousX = x
        
        let startingPoint = CGPoint(x: x, y: bounds.size.height)
        let endPoint = CGPoint(x: x, y: 16 + 8)
        drawLine(onLayer: layer, fromPoint: startingPoint, toPoint: endPoint)
        
        let maxValue = visibleLines.compactMap({ Array($0.values[correctRange])[coeffIndex] }).max() ?? 0
        let numberOfDigits = "\(maxValue)".count
        let infoHeight: CGFloat = max(20.0 * CGFloat(visibleLines.count), 40.0)
        let infoWidth: CGFloat = max(60 + CGFloat(numberOfDigits) * 12.0, 80.0)
        let infoSize = CGSize(width: infoWidth, height: infoHeight)
        
        let datesAxis = Array(dateAxis[correctRange])
        let date = datesAxis[coeffIndex]
        
        for line in visibleLines {
            guard let view = layer.sublayers?
                .compactMap({ $0 as? LineView })
                .first(where: { $0.line.id == line.id }) else {
                    return true
            }
            
            let calculatedPoints: [CGPoint] = view.calculatedPoints
                .map({ CGPoint(x: $0.x + view.frame.origin.x, y: $0.y) })
                .filter({ $0.x >= 0.0 && $0.x <= view.frame.width - view.frame.origin.x })
            let point = calculatedPoints[coeffIndex]
            
            let circleLayer = CAShapeLayer()
            let circleSize: CGFloat = 4.0
            let originCirclePoint = CGPoint(x: point.x - circleSize / 2.0, y: point.y - circleSize / 2.0)
            let circleRect = CGRect(origin: originCirclePoint, size: CGSize(width: circleSize, height: circleSize))
            circleLayer.path = UIBezierPath(ovalIn: circleRect).cgPath
            circleLayer.fillColor = backgroundColor?.cgColor
            circleLayer.strokeColor = line.color.cgColor
            layer.addSublayer(circleLayer)
            tempLayers.append(circleLayer)
        }
        
        let minPointX: CGFloat = -2.0
        let maxPointX = bounds.width - infoWidth
        
        drawInfo(onLayer: layer,
                 atPoint: CGPoint(x: max(min(x - infoWidth / 2.0, maxPointX), minPointX), y: 16),
                 withSize: infoSize,
                 date: date,
                 lines: visibleLines,
                 currentValueIndex: coeffIndex)
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        removeTempInfoLayers()
    }
    
    func removeTempInfoLayers() {
        for sublayer in (layer.sublayers ?? []) {
            if tempLayers.contains(sublayer) {
                sublayer.removeFromSuperlayer()
            }
        }
        tempLayers.removeAll()
    }
    
    func removeTempLayers(inArray array: [CALayer]) {
        for sublayer in (layer.sublayers ?? []) {
            if array.contains(sublayer) {
                sublayer.removeFromSuperlayer()
            }
        }
    }
    
    func drawLine(onLayer layer: CALayer, fromPoint start: CGPoint, toPoint end: CGPoint) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = nil
        line.opacity = 1.0
        line.strokeColor = UIColor(hexString: "cbd3dd").withAlphaComponent(0.2).cgColor
        layer.addSublayer(line)
        tempLayers.append(line)
    }
    
    private var dateFormatters = DateFormatters()
    
    func drawInfo(onLayer layer: CALayer,
                  atPoint point: CGPoint,
                  withSize size: CGSize,
                  date: Date,
                  lines: [Line],
                  currentValueIndex: Int) {
        let infoLayer = CAShapeLayer()
        let rect = CGRect(origin: point, size: size)
        let info = UIBezierPath(roundedRect: rect, cornerRadius: 8.0)
        infoLayer.path = info.cgPath
        infoLayer.fillColor = Colors.shared.backgroundColor.cgColor
        infoLayer.opacity = 1.0
        
        let commonInset: CGFloat = 4.0
        let insetFromLeft: CGFloat = rect.origin.x + commonInset
        let insetFromRight: CGFloat = rect.origin.x + rect.width - commonInset
        let insetFromTop: CGFloat = rect.origin.y + commonInset
        let insetFromBottom: CGFloat = rect.origin.y + rect.height - commonInset
        let inset = UIEdgeInsets(top: insetFromTop,
                                 left: insetFromLeft,
                                 bottom: insetFromBottom,
                                 right: insetFromRight)
        
        let dateRect = CGRect(x: inset.left, y: inset.top, width: rect.width / 2.0 + commonInset, height: min(rect.height / 2.0, 20))
        let dateText = dateFormatters.format(date: date)
        let datelLayer = getLabelLayer(title: dateText,
                                           frame: dateRect,
                                           font: UIFont.boldSystemFont(ofSize: 12.0),
                                           color: Colors.shared.secondaryCColor,
                                           alignment: .left)
        infoLayer.addSublayer(datelLayer)
        
        let yearRect = CGRect(x: inset.left, y: inset.top + dateRect.height, width: rect.width / 2.0, height: min(rect.height / 2.0, 20))
        let yearText = dateFormatters.formatDateToYear(date: date)
        let yearLayer = getLabelLayer(title: yearText,
                                           frame: yearRect,
                                           font: UIFont.systemFont(ofSize: 10.0),
                                           color: Colors.shared.secondaryCColor,
                                           alignment: .left)
        infoLayer.addSublayer(yearLayer)
        
        let lineCountHeight = min(rect.height / CGFloat(lines.count), 20)
        let lineCountWidth = rect.width / 2.0
        for (index, line) in lines.enumerated() {
            let lineCountRect = CGRect(x: inset.right - lineCountWidth,
                                       y: insetFromTop + CGFloat(index) * lineCountHeight,
                                       width: lineCountWidth,
                                       height: lineCountHeight)
            let lineCountText = line.values[currentValueIndex].description
            let lineCountLayer = getLabelLayer(title: lineCountText,
                                               frame: lineCountRect,
                                               font: UIFont.boldSystemFont(ofSize: 12.0),
                                               color: line.color,
                                               alignment: .right)
            infoLayer.addSublayer(lineCountLayer)
        }
        
        layer.addSublayer(infoLayer)
        tempLayers.append(infoLayer)
    }
    
    func getLabelLayer(title: String,
                       frame: CGRect,
                       font: UIFont,
                       color: UIColor,
                       alignment: CATextLayerAlignmentMode) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.frame = frame
        textLayer.foregroundColor = color.cgColor
        textLayer.backgroundColor = UIColor.clear.cgColor
        textLayer.alignmentMode = alignment
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.font = CTFontCreateWithName(font.fontName as CFString, 0, nil)
        textLayer.fontSize = font.pointSize
        textLayer.string = title
        return textLayer
    }
    
}
