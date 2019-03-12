//
//  GraphView.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit
import QuartzCore

class GraphView: UIView {
    
    private var graph: Chart = Chart(dateAxis: [], lines: [])
    
    private var xAxis: [Date] = []
    private var yAxises: [Line] = []
    
    private var yAxis: Line = Line(id: UUID().uuidString, name: "", values: [], color: .clear, isVisible: true)
    
    private let padding: CGFloat = 8.0
    private var graphWidth: CGFloat = 0
    private var graphHeight: CGFloat = 0
    private var axisWidth: CGFloat = 0
    private var axisHeight: CGFloat = 0
    private var everest: CGFloat = 0
    
    private var dateFormatters = DateFormatters()
    
    var showFull = false
    var showLines = true
    var showPoints = false
    var showYLabels = true
    var showXLabels = true
    var linesColor: UIColor = UIColor(hexString: "CDCFDF")
    var graphColor: UIColor = .black
    var labelFont: UIFont = .systemFont(ofSize: 12)
    var labelTextColor: UIColor = UIColor(hexString: "CDCFDF")
    var xAxisColor: UIColor = .black
    var yAxisColor: UIColor = .black
    var yIntervals: CGFloat = 6
    let xIntervals: CGFloat = 6
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, chart: Chart) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.xAxis = chart.dateAxis
        self.yAxises = chart.lines
    }
    
    init(frame: CGRect, xAxis: [Date], yAxises: [Line]) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.xAxis = xAxis
        self.yAxises = yAxises
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let roundToValue: CGFloat = 10
        
        // Graph size
        graphWidth = rect.size.width
        graphHeight = rect.size.height
        axisWidth = rect.size.width
        axisHeight = rect.size.height - padding
        
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError()
        }
        
        // Lets work out the highest value and round to the nearest `roundToValue`.
        // This will be used to work out the position of each value
        // on the Y axis, it essentialy reperesents 100% of Y
        let maxValue = CGFloat(yAxises.flatMap({ $0.values }).max() ?? 0)
        if maxValue > everest {
            everest = CGFloat(Int(ceilf(Float(maxValue) / Float(roundToValue)) * Float(roundToValue)))
        }
        
        if everest == 0 {
            everest = roundToValue
        }
        
        context.setStrokeColor(xAxisColor.cgColor)
        context.strokePath()
        
        context.setStrokeColor(yAxisColor.cgColor)
        context.strokePath()
        
        let yLabelInterval = Int(everest / yIntervals)
        
        // Draw Y labels and lines if needed
        if showYLabels || showLines {
            for i in 0..<Int(yIntervals) {
                let y = floor((rect.size.height - padding) - CGFloat(i) * (axisHeight / yIntervals))
                
                if showYLabels {
                    let labelHeight: CGFloat = 20.0
                    let inset: CGFloat = 8.0
                    
                    let label = axisLabel(title: String(format: "%d", i * yLabelInterval), alignment: .left)
                    label.frame = CGRect(x: inset,
                                         y: y - labelHeight,
                                         width: 40,
                                         height: labelHeight)
                    addSubview(label)
                }
                
                if showLines {
                    let line = CGMutablePath()
                    line.move(to: CGPoint(x: padding,
                                          y: y))
                    line.addLine(to: CGPoint(x: axisWidth,
                                             y: y))
                    context.addPath(line)
                    context.setLineWidth(1)
                    context.setStrokeColor(linesColor.cgColor)
                    context.strokePath()
                }
            }
        }
        
        // Draw X labels is needed
        if showXLabels {
            for (index, x) in xAxis.enumerated() {
                let interval: CGFloat
                
                if showFull {
                    interval = graphWidth / CGFloat(xAxis.count)
                } else {
                    let elements: CGFloat = 6.0
                    interval = graphWidth / elements
                }
                
                let xPosition = CGFloat(index) * interval
                let title = dateFormatters.format(date: x)
                let xLabel = axisLabel(title: title)
                xLabel.frame = CGRect(x: xPosition - interval / 2.0, y: graphHeight + 20, width: interval, height: 20)
                xLabel.textAlignment = .center
                addSubview(xLabel)
            }
        }
        
        // Draw graph for each Line object
        for yAxis in yAxises {
            self.yAxis = yAxis
            self.graphColor = yAxis.color
            
            let pointPath = CGMutablePath()
            let initialY: CGFloat = ceil((CGFloat(yAxis.values[0]) * (axisHeight / everest)))
            let initialX: CGFloat = 0
            pointPath.move(to: CGPoint(x: initialX, y: graphHeight - initialY))
            
            for value in zip(xAxis, yAxis.values).dropFirst() {
                plotPoint(point: (value.0, value.1), path: pointPath)
            }
            
            context.addPath(pointPath)
            context.setLineWidth(2)
            context.setStrokeColor(graphColor.cgColor)
            context.strokePath()
        }
    }
    
    func plotPoint(point: (Date, Int), path: CGMutablePath) {
        let interval: CGFloat
            
        if showFull {
            interval = graphWidth / CGFloat(xAxis.count - 1)
        } else {
            interval = graphWidth / xIntervals
        }
        
        let yPosition: CGFloat = ceil((CGFloat(point.1) * (axisHeight / everest)))
        
        var pointIndex = 0
        if let index = xAxis.index(ofElement: point.0) {
            pointIndex = index
        }
        
        let xPosition = CGFloat(pointIndex) * interval
        
        path.addLine(to: CGPoint(x: xPosition, y: graphHeight - yPosition))
    }
    
    func axisLabel(title: String, alignment: NSTextAlignment = .right) -> UILabel {
        let label = UILabel(frame: .zero)
        label.text = title as String
        label.font = labelFont
        label.textColor = labelTextColor
        label.backgroundColor = backgroundColor
        label.textAlignment = alignment
        return label
    }
    
}
