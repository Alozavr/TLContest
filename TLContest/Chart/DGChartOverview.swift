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
        let lineView = GraphView(frame: bounds, xAxis: chart.dateAxis, yAxises: chart.lines)
        lineView.showXLabels = false
        lineView.showFull = true
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
        lineView.bindToSuperView()
    }
    
}
