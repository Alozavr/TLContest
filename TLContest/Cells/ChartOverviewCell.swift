//
//  ChartOverviewCell.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartOverviewCell: UITableViewCell {
    
    weak var graph: GraphView!
    weak var chartView: ChartOverview!
    
    var previousLowerRangeValue: Double = 0
    var previousUpperRangeValue: Double = 0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initChart()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initChart()
    }

    private func initChart() {
        selectionStyle = .none
        
        let graph = GraphView()
        graph.backgroundColor = .white
        graph.translatesAutoresizingMaskIntoConstraints = false
        addSubview(graph)
        
        let chartView = ChartOverview()
        chartView.slider.lowerValue = 0.8
        chartView.slider.upperValue = 1.0
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)
        
        chartView.slider.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
        
        graph.topAnchor.constraint(equalTo: topAnchor).isActive = true
        graph.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        graph.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        graph.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        chartView.topAnchor.constraint(equalTo: topAnchor, constant: 200 + 32).isActive = true
        chartView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        chartView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        self.graph = graph
        self.chartView = chartView
        
        let lowerBoundIndex = Int(Double(graph.xAxis.count) * (chartView.slider.lowerValue))
        let upperBoundIndex = Int(Double(graph.xAxis.count) * (chartView.slider.upperValue))
        graph.lowerBoundIndex = lowerBoundIndex
        graph.upperBoundIndex = upperBoundIndex
        graph.xIntervals = CGFloat(Double(graph.xAxis.count) * (chartView.slider.upperValue - chartView.slider.lowerValue)).rounded(.up)
    }
    
    func setChart(_ chart: Chart) {
        graph.setChart(chart)
        chartView.displayChart(chart)
    }
    
    @objc func sliderDidChangeValue() {
        if fabs(previousLowerRangeValue - chartView.slider.lowerValue) > 0.05 || fabs(previousUpperRangeValue - chartView.slider.upperValue) > 0.05 {
            let lowerBoundIndex = Int(Double(graph.xAxis.count) * (chartView.slider.lowerValue))
            let upperBoundIndex = Int(Double(graph.xAxis.count) * (chartView.slider.upperValue))
            graph.lowerBoundIndex = lowerBoundIndex
            graph.upperBoundIndex = upperBoundIndex
            graph.xIntervals = CGFloat(Double(graph.xAxis.count) * (chartView.slider.upperValue - chartView.slider.lowerValue)).rounded(.up)
        }
    }
}
