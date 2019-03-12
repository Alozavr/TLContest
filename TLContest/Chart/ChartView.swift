//
//  ChartView.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartView: UIView {
    
    var xAxisCoefficients: [CGFloat] = []
    
//    func setLineVisible(newLine: Line) {
//        guard let view = subviews.first(where: { ($0 as? LineView)?.line.id == newLine.id }) as? LineView else { return }
//        view.line = newLine
//        view.isHidden = !newLine.isVisible
//    }
    
    func refresh(chart: Chart) {
        let viewsToRemove = subviews.compactMap { (subView) -> LineView? in
            guard let lineView = subView as? LineView else { return nil }
            guard let line = chart.lines.first(where: { $0.id == lineView.line.id }), line.isVisible == false else {
                return nil
            }
            return lineView
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            for view in viewsToRemove {
                view.alpha = 0
            }
        }) { (_) in
            for view in viewsToRemove {
                view.removeFromSuperview()
            }
        }
        
    }

    
    func displayChart(_ chart: Chart) {
        guard let lastDate = chart.dateAxis.last?.timeIntervalSince1970,
            let firstDate = chart.dateAxis.first?.timeIntervalSince1970 else { return }
        
        xAxisCoefficients = chart.dateAxis.map({ CGFloat( ($0.timeIntervalSince1970 - firstDate) / (lastDate - firstDate)) })
        
        let lines = chart.lines.filter { $0.isVisible }
        let joinedYValues = lines.reduce([], { $0 + $1.values.map({ CGFloat($0) })})
        guard let max = joinedYValues.max(), let min = joinedYValues.min() else { return }
        
        for line in lines {
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
