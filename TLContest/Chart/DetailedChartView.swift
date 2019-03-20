//
//  DetailedChartView.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 13/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class DetailedChartView: UIView {
    
    var chartView: RangedChartView!
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let chartView = RangedChartView()
        chartView.backgroundColor = Colors.shared.primaryColor
        
        addSubview(chartView)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        chartView.bindToSuperView()
        
        self.chartView = chartView
    }
    
    init(frame: CGRect, chart: Chart) {
        super.init(frame: frame)
        backgroundColor = .clear
        chartView.displayFullChart(chart)
    }
    
    func displayChart(_ chart: Chart) {
        chartView.displayFullChart(chart)
    }
    
}
