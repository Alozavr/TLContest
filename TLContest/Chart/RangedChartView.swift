//
//  RangedChartView.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 13/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class RangedChartView: UIControl {
    
    var xAxisCoefficients: [CGFloat] = []
    
    var dateAxis: [Date] = []
    var visibleLines: [Line] = []
    var lineCoefficients: [Int: [CGFloat]] = [:]
    
    var fullChart: Chart = Chart(dateAxis: [], lines: [])
    var selectedRange: ClosedRange = ClosedRange(uncheckedBounds: (0, 0))
    
    func displayFullChart(_ chart: Chart) {
        self.fullChart = chart
        let lowerRage = 0
        let upperRange = chart.dateAxis.count
        let selectedRange = ClosedRange(uncheckedBounds: (lowerRage, upperRange))
        displayChart(withRange: selectedRange)
    }
    
    func displayChart(withRange range: ClosedRange<Int>) {
        let newDateAxis = Array(fullChart.dateAxis[range.lowerBound..<range.upperBound])
        if newDateAxis != dateAxis {
            xAxisCoefficients.removeAll()
        }
        self.selectedRange = range
        self.dateAxis = newDateAxis
        calculateXAxisCoefficients(range: range)
        
        let viewsToRemove = layer.sublayers?.compactMap { (subView) -> LineView? in
            guard let lineView = subView as? LineView else { return nil }
            guard let line = fullChart.lines.first(where: { $0.id == lineView.line.id }) else {
                return nil
            }
            lineView.line = line
            return !line.isVisible ? lineView : nil
            } ?? []
        
        for view in viewsToRemove {
            view.animateDisappearence(removeOnComplete: false)
        }
        
        var lines = fullChart.lines.filter { $0.isVisible }
        
        for index in lines.indices {
            let line = lines[index]
            let newValues = Array(line.values[range.lowerBound..<range.upperBound])
            let newLine = Line(id: line.id,
                               name: line.name,
                               values: newValues,
                               color: line.color,
                               isVisible: line.isVisible)
            lines[index] = newLine
        }
        
        self.visibleLines = lines
        
        for line in lines {
            guard let view = layer.sublayers?.compactMap({ $0 as? LineView }).first(where: { $0.line.id == line.id }) else {
                createLineView(line: line, coefficients: [])
                continue
            }
            if view.opacity == 0 { view.animateAppearence() }
            view.updatePath()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let sublayers = layer.sublayers else { return }
        for layer in sublayers {
            layer.frame = self.bounds
            layer.setNeedsDisplay()
        }
    }
    
    private func createLineView(line: Line, coefficients: [(x: CGFloat, y: CGFloat)]) {
        let lineView = LineView(frame: self.bounds, line: line, coefficients: coefficients)
        layer.addSublayer(lineView)
        lineView.animateAppearence()
        lineView.lineDelegate = self
    }
    
    
    private func calculateXAxisCoefficients(range: ClosedRange<Int>) {
        guard xAxisCoefficients.isEmpty,
            let lastDate = fullChart.dateAxis[safe: range.upperBound - 1]?.timeIntervalSince1970,
            let firstDate = fullChart.dateAxis[safe: range.lowerBound]?.timeIntervalSince1970 else { return }
        
        xAxisCoefficients = fullChart.dateAxis[range.lowerBound..<range.upperBound].map({ CGFloat( ($0.timeIntervalSince1970 - firstDate) / (lastDate - firstDate)) })
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
        
        let characteristicSize: CGFloat = 1.0 / CGFloat(xAxisCoefficients.count)
        let delta: CGFloat = characteristicSize
        
        guard let coeff = xAxisCoefficients.filter({ $0 > location.x / bounds.width - delta && $0 < location.x / bounds.width + delta }).first,
            let coeffIndex = xAxisCoefficients.index(ofElement: coeff) else  {
            return true
        }
            
        let x = coeff *  bounds.width
        
        if previousX != x {
            removeTempInfoLayers()
            impact.impactOccurred()
        }
        
        previousX = x
        
        let startingPoint = CGPoint(x: x, y: bounds.size.height)
        let endPoint = CGPoint(x: x, y: 16)
        drawLine(onLayer: layer, fromPoint: startingPoint, toPoint: endPoint)
        
        let maxValue = visibleLines.compactMap({ $0.values[coeffIndex] }).max() ?? 0
        let numberOfDigits = "\(maxValue)".count
        let infoHeight: CGFloat = max(20.0 * CGFloat(visibleLines.count), 40.0)
        let infoWidth: CGFloat = max(60 + CGFloat(numberOfDigits) * 12.0, 80.0)
        let infoSize = CGSize(width: infoWidth, height: infoHeight)
        let date = dateAxis[coeffIndex]
        
        let minPointX: CGFloat = -8.0
        let maxPointX = bounds.width - infoWidth + 8.0
        
        drawInfo(onLayer: layer,
                 atPoint: CGPoint(x: max(min(x - infoWidth / 2.0, maxPointX), minPointX), y: 16),
                 withSize: infoSize,
                 date: date,
                 lines: visibleLines,
                 currentValueIndex: coeffIndex)
        
        for (index, line) in visibleLines.enumerated() {
            guard line.values.count > coeffIndex,
                let yCoefficients = lineCoefficients[index],
                yCoefficients.count > coeffIndex else {
                continue
            }
            
            let yCoeff = yCoefficients[coeffIndex]
            
            let y = bounds.height - yCoeff * bounds.height
            let point = CGPoint(x: x, y: y)
            
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
        tempLayers.removeAll()
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

extension RangedChartView: LineViewDelegate {
    func getCoefficients(forLine lineView: LineView) -> [(x: CGFloat, y: CGFloat)] {
        guard let lineElement = visibleLines.enumerated().first(where: { $0.element.id == lineView.line.id }) else {
            return []
        }
        let line = lineElement.element
        let index = lineElement.offset
        
        guard let max = visibleLines.flatMap({ $0.values }).max() else { return [] }
        let min: CGFloat = 0
        
        let lineCoefficients = line.values.map({ CGFloat($0) }).map({ ($0 - min) / (CGFloat(max) - min) })
        self.lineCoefficients[index] = lineCoefficients
        guard lineCoefficients.count == xAxisCoefficients.count else { return [] }
        let coefficients = zip(xAxisCoefficients, lineCoefficients).map({ (x:$0, y:$1) })
        return coefficients
    }
}

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
