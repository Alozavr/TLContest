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
    var scrollLayer = CAScrollLayer()
    var currentRange = ClosedRange<Int>(uncheckedBounds: (0, 0))
    
    var animator: HeightAnimator!
    
    var previousMax: CGFloat = 0.0
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        animator = HeightAnimator(startValue: 0, endValue: 0, delegate: self)
        layer.addSublayer(scrollLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        animator = HeightAnimator(startValue: 0, endValue: 0, delegate: self)
        layer.addSublayer(scrollLayer)
    }
    
    func needsRedraw(currentHeight: CGFloat) {
        print("currentValue: \(currentHeight)")
        redrawLines(maxHeight: currentHeight)
    }
    
    func redrawLines(maxHeight: CGFloat) {
        let min: CGFloat = 0
        
        for (index, line) in visibleLines.enumerated() {
            let lineCoefficients = line.values.map({ (CGFloat($0) - min) / (maxHeight - min) })
            self.lineCoefficients[index] = lineCoefficients
            guard lineCoefficients.count == xAxisCoefficients.count else { continue }
            guard let view = scrollLayer.sublayers?.compactMap({ $0 as? LineView }).first(where: { $0.line.id == line.id }) else {
                continue
            }
            if view.opacity == 0 { view.animateAppearence() }
            view.yCoefficients = lineCoefficients
            view.updatePath()
        }
    }
    
    func displayChart(chart: Chart, yRange: ClosedRange<Int>) {
        currentRange = yRange

//        if chart.dateAxis != dateAxis {
//            xAxisCoefficients.removeAll()
//        }
        
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
        let max = CGFloat(tempMax)
        
        var isAnimateFromTopToBottom: Bool = false
        
        if max > previousMax {
            isAnimateFromTopToBottom = true
        } else if max < previousMax {
            isAnimateFromTopToBottom = false
        }
        
        if max != previousMax && previousMax != 0 {
            animator.startAnimation(startValue: previousMax, endValue: max)
            previousMax = max
            return
        }
        previousMax = max
        if animator.isAnimating { return }
        // MARK: Delete if need to start Y axis not from 0
        let min: CGFloat = 0
        
        for (index, line) in lines.enumerated() {
            let lineCoefficients = line.values.map({ (CGFloat($0) - min) / (max - min) })
            self.lineCoefficients[index] = lineCoefficients
            guard lineCoefficients.count == xAxisCoefficients.count else { continue }
            let coefficients = zip(xAxisCoefficients, lineCoefficients).map({ (x:$0, y:$1) })
            guard let view = scrollLayer.sublayers?.compactMap({ $0 as? LineView }).first(where: { $0.line.id == line.id }) else {
                createLineView(line: line, coefficients: coefficients)
                continue
            }
            view.shouldAnimate = willAnimate
            if view.opacity == 0 { view.animateAppearence() }
            view.xCoefficients = xAxisCoefficients
            view.updatePath()
        }

        removeTempLayers(inArray: tempLineLayers)
        tempLineLayers.removeAll()

        let linesCount = 5
        let yLabelInterval = max / CGFloat(linesCount)
        for i in 1...linesCount {
            let y = bounds.height / CGFloat(linesCount) * CGFloat(i)
            let labelHeight: CGFloat = 20.0
            let inset: CGFloat = 8.0

            let title = String(format: "%d", Int(yLabelInterval * CGFloat(linesCount - i)))
            let labelFrame = CGRect(x: inset,
                                    y: y - labelHeight,
                                    width: CGFloat(title.count) * 12.0,
                                    height: labelHeight)

            let container = CAShapeLayer()
            container.frame = labelFrame
            let textLayer = getLabelLayer(title: title,
                                          frame: labelFrame,
                                          font: .systemFont(ofSize: 12.0),
                                          color: Colors.shared.secondaryAColor,
                                          alignment: .left)
            container.addSublayer(textLayer)
            layer.addSublayer(container)

            let lineLayer = CAShapeLayer()
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: inset,
                                       y: y))
            linePath.addLine(to: CGPoint(x: bounds.width,
                                     y: y))
            linePath.lineWidth = 1.0
            lineLayer.strokeColor = Colors.shared.secondaryAColor.cgColor
            lineLayer.path = linePath.cgPath
            layer.addSublayer(lineLayer)

            tempLineLayers.append(lineLayer)
            tempLineLayers.append(container)

            lineLayer.animateOpacityWithPosition(with: 0.3,
                                                 isAnimateFromTopToBottom: isAnimateFromTopToBottom,
                                                 index: i)
            textLayer.animateOpacityWithPosition(with: 0.3,
                                                 isAnimateFromTopToBottom: isAnimateFromTopToBottom,
                                                 index: i)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let sublayers = layer.sublayers else { return }
        for layer in sublayers {
            guard layer.frame.isEmpty else { continue }
            layer.frame = self.bounds
            layer.setNeedsDisplay()
        }
        guard let lineSublayers = scrollLayer.sublayers else { return }
        for layer in lineSublayers {
            guard layer.frame.isEmpty else { continue }
            layer.frame = self.bounds
            layer.setNeedsDisplay()
        }
    }
    
    private func createLineView(line: Line, coefficients: [(x: CGFloat, y: CGFloat)]) {
        let lineView = LineView(frame: self.bounds, line: line, coefficients: coefficients)
        scrollLayer.addSublayer(lineView)
        lineView.animateAppearence()
    }
    
    private func calculateXAxisCoefficients(_ chart: Chart) {
        guard xAxisCoefficients.isEmpty,
            let lastDate = chart.dateAxis.last?.timeIntervalSince1970,
            let firstDate = chart.dateAxis.first?.timeIntervalSince1970 else { return }
        xAxisCoefficients = chart.dateAxis.map({ CGFloat( ($0.timeIntervalSince1970 - firstDate) / (lastDate - firstDate)) })
    }
    
    private func findMaxY(in lines: [Line], with range: ClosedRange<Int>) -> CGFloat? {
        var frameOfLine2 = layer.sublayers?.first?.frame
        if range.count == xAxisCoefficients.count {
            frameOfLine2 = self.frame
        }
        guard let frameOfLine = frameOfLine2 else { return nil }
        let lowestBound = range.lowerBound == 0 ? range.lowerBound : range.lowerBound - 1
        let upperBound = range.upperBound == xAxisCoefficients.count - 1 ? range.upperBound : range.upperBound + 1
        
        let leftBorderX = abs(frameOfLine.origin.x)
        let possibleLeftX = xAxisCoefficients[lowestBound] * frameOfLine.width
        let originalLeftX = xAxisCoefficients[range.lowerBound] * frameOfLine.width
        var maxLeftY: CGFloat?
        
        if possibleLeftX != originalLeftX, let fd = dateAxis.first?.timeIntervalSince1970, let ld = dateAxis.last?.timeIntervalSince1970 {
            let R = leftBorderX - possibleLeftX
            let leftDateOfCrossing = (R * CGFloat(ld - fd) / frameOfLine.width) + CGFloat(dateAxis[lowestBound].timeIntervalSince1970)
            
            for line in lines {
                let x1 = CGFloat(dateAxis[lowestBound].timeIntervalSince1970)
                let y1 = CGFloat(line.values[lowestBound])
                let x2 = CGFloat(dateAxis[range.lowerBound].timeIntervalSince1970)
                let y2 = CGFloat(line.values[range.lowerBound])
                let x3 = leftDateOfCrossing
                let y3: CGFloat = 0.0
                let x4 = x3
                let y4: CGFloat = 1
                
                let crossY = findCrossingYBetween(x1: x1, y1: y1, x2: x2, y2: y2, x3: x3, y3: y3, x4: x4, y4: y4)
                if crossY > 0 {
                    maxLeftY = max(maxLeftY ?? 0, crossY)
                }
            }
        }
        
        guard let intMaxInValues = lines.compactMap({ $0.values[range].max() }).max() else {
            return nil
        }
        let maxOfVisible = CGFloat(intMaxInValues)
        
        guard let maxInvisibleY = maxLeftY else {
            return maxOfVisible
        }
        return max(maxOfVisible, maxInvisibleY)
    }
    
    private func findCrossingYBetween(x1: CGFloat, y1: CGFloat, x2: CGFloat, y2: CGFloat, x3: CGFloat, y3: CGFloat, x4: CGFloat, y4: CGFloat) -> CGFloat {
        let up = (x1*y2 - y1*x2)*(y3 - y4) - (y1-y2)*(x3*y4 - x4*y3)
        let down = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4)
        return up/down
    }
    
    // MARK: - Touches
    
    private var previousLocation = CGPoint()
    private var tempLayers: [CALayer] = []
    private var tempLineLayers: [CALayer] = []
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
        
        guard let coeffIndex = view.calculatedPoints.index(where: { $0.x > location.x - delta && $0.x < location.x + delta }) else  {
            return true
        }
        
        let correctRange = ClosedRange(uncheckedBounds: (max(currentRange.lowerBound, 0),
                                                         max(currentRange.upperBound, coeffIndex)))
        
        let x = view.calculatedPoints[coeffIndex].x
        
        if previousX != x {
            removeTempInfoLayers()
            impact.impactOccurred()
        }
        
        previousX = x
        
        let startingPoint = CGPoint(x: x, y: bounds.size.height)
        let endPoint = CGPoint(x: x, y: 16)
        drawLine(onLayer: layer, fromPoint: startingPoint, toPoint: endPoint)
        
        let maxValue = visibleLines.compactMap({ Array($0.values[correctRange])[coeffIndex] }).max() ?? 0
        let numberOfDigits = "\(maxValue)".count
        let infoHeight: CGFloat = max(20.0 * CGFloat(visibleLines.count), 40.0)
        let infoWidth: CGFloat = max(60 + CGFloat(numberOfDigits) * 12.0, 80.0)
        let infoSize = CGSize(width: infoWidth, height: infoHeight)
        
        let datesAxis = Array(dateAxis[correctRange])
        let date = datesAxis[coeffIndex]
        
        let minPointX: CGFloat = -2.0
        let maxPointX = bounds.width - infoWidth - 2.0
        
        drawInfo(onLayer: layer,
                 atPoint: CGPoint(x: max(min(x - infoWidth / 2.0, maxPointX), minPointX), y: 16),
                 withSize: infoSize,
                 date: date,
                 lines: visibleLines,
                 currentValueIndex: coeffIndex)
        
        for line in visibleLines {
            guard let view = layer.sublayers?
                .compactMap({ $0 as? LineView })
                .first(where: { $0.line.id == line.id }) else {
                    return true
            }
            
            let point = view.calculatedPoints[coeffIndex]
            
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
        line.strokeColor = UIColor.lightGray.cgColor
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
        infoLayer.fillColor = UIColor(hexString: "FAFAFA").cgColor
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
                                           color: UIColor(hexString: "77777c"),
                                           alignment: .left)
        infoLayer.addSublayer(datelLayer)
        
        let yearRect = CGRect(x: inset.left, y: inset.top + dateRect.height, width: rect.width / 2.0, height: min(rect.height / 2.0, 20))
        let yearText = dateFormatters.formatDateToYear(date: date)
        let yearLayer = getLabelLayer(title: yearText,
                                           frame: yearRect,
                                           font: UIFont.systemFont(ofSize: 10.0),
                                           color: UIColor(hexString: "77777c"),
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
