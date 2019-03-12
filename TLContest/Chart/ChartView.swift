//
//  ChartView.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartView: UIView {
    
    func hideLine(named: String) {
        
    }
    
    func displayChart(_ chart: Chart) {
        guard let lastDate = chart.dateAxis.last?.timeIntervalSince1970,
            let firstDate = chart.dateAxis.first?.timeIntervalSince1970 else { return }
        
        let xAxisCoefficients = chart.dateAxis.map({ CGFloat( ($0.timeIntervalSince1970 - firstDate) / (lastDate - firstDate)) })
        
        let joinedYValues = chart.lines.reduce([], { $0 + $1.values.map({ CGFloat($0) })})
        guard let max = joinedYValues.max(), let min = joinedYValues.min() else { return }
        
        for line in chart.lines {
            let lineCoefficients = line.values.map({ CGFloat($0) }).map({ CGFloat( ($0 - min) / (max - min) ) })
            guard lineCoefficients.count == xAxisCoefficients.count else { continue }
            let coefficients = zip(xAxisCoefficients, lineCoefficients).map({ (x:$0, y:$1) })
            let lineView = LineView(frame: self.bounds, line: line, coefficients: coefficients)
            lineView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(lineView)
            lineView.bindToSuperView()
        }
    }

}
