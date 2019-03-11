//
//  DGChartOverview.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class DGChartOverview: UIView {
     var lineViews = [LineView]()
    
    func displayChart(_ chart: Chart) {
        guard let lastDate = chart.dateAxis.last?.timeIntervalSince1970,
            let firstDate = chart.dateAxis.first?.timeIntervalSince1970 else { return }
        let wholeValue = abs(lastDate - firstDate)
        
        var shifts = [CGFloat]()
        var previousValue: TimeInterval = firstDate
        for value in chart.dateAxis.dropFirst() {
            let diff = value - previousValue
            
        }
        
        let xShifts = chart.dateAxis.
//        for line in chart.lines {
//            let lineView = LineView(frame: self.bounds, line: line)
//            lineView.translatesAutoresizingMaskIntoConstraints = false
//            addSubview(lineView)
//            lineView.bindToSuperView()
//        }
    }
    
}
