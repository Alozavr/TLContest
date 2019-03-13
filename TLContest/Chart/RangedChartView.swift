//
//  RangedChartView.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 13/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class RangedChartView: UIView {
    
    var xAxisCoefficients: [CGFloat] = []
    
    var dateAxis: [Date] = []
    
    func displayChart(chart: Chart) {
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
        let joinedYValues = lines.reduce([], { $0 + $1.values.map({ CGFloat($0) })})
        guard let max = joinedYValues.max(), let min = joinedYValues.min() else { return }
        
        for line in lines {
            let lineCoefficients = line.values.map({ CGFloat($0) }).map({ CGFloat( ($0 - min) / (max - min) ) })
            guard lineCoefficients.count == xAxisCoefficients.count else { continue }
            let coefficients = zip(xAxisCoefficients, lineCoefficients).map({ (x:$0, y:$1) })
            guard let view = layer.sublayers?.compactMap({ $0 as? LineView }).first(where: { $0.line.id == line.id }) else {
                createLineView(line: line, coefficients: coefficients)
                continue
            }
            if view.opacity == 0 { view.animateAppearence() }
            view.coefficients = coefficients
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
    }
    
    
    private func calculateXAxisCoefficients(_ chart: Chart) {
        guard xAxisCoefficients.isEmpty,
            let lastDate = chart.dateAxis.last?.timeIntervalSince1970,
            let firstDate = chart.dateAxis.first?.timeIntervalSince1970 else { return }
        
        xAxisCoefficients = chart.dateAxis.map({ CGFloat( ($0.timeIntervalSince1970 - firstDate) / (lastDate - firstDate)) })
    }
    
}
