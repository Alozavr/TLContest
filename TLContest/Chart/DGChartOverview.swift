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
        for line in chart.lines {
            let lineView = LineView(frame: self.bounds, line: line)
            lineView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(lineView)
            lineView.bindToSuperView()
        }
    }
    
}
