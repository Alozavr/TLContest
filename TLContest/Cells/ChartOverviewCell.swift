//
//  ChartOverviewCell.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartOverviewCell: UITableViewCell {
    
    weak var graph: DetailedChartView!
    weak var chartView: ChartOverview!
    
    var previousLowerRangeValue: Double = 0
    var previousUpperRangeValue: Double = 0
    
    var chart: Chart!
    
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
        contentView.backgroundColor = Colors.shared.primaryColor
        backgroundColor = Colors.shared.primaryColor
        
        let graph = DetailedChartView()
        graph.backgroundColor = Colors.shared.primaryColor
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
    }
    
    func setChart(_ chart: Chart) {
        self.chart = chart
        graph.displayChart(chart)
        chartView.displayChart(chart)
        sliderDidChangeValue()
    }
    
    @objc func sliderDidChangeValue() {
        if fabs(previousLowerRangeValue - chartView.slider.lowerValue) > 0.05 ||
            fabs(previousUpperRangeValue - chartView.slider.upperValue) > 0.05 {
            let oldDateAxis = self.chart.dateAxis
            
            let lowerBoundIndex = Int(Double(oldDateAxis.count) * (chartView.slider.lowerValue))
            let upperBoundIndex = Int(Double(oldDateAxis.count) * (chartView.slider.upperValue))
            
            var newDateAxis = oldDateAxis
            if upperBoundIndex > lowerBoundIndex, oldDateAxis.count >= upperBoundIndex {
                newDateAxis = Array(oldDateAxis[lowerBoundIndex..<upperBoundIndex])
            }
            
            var lines: [Line] = []
            for line in chart.lines {
                var newLine = line
                if upperBoundIndex > lowerBoundIndex, line.values.count >= upperBoundIndex {
                    let newValues = Array(newLine.values[lowerBoundIndex..<upperBoundIndex])
                    newLine = Line(id: line.id,
                                   name: line.name,
                                   values: newValues,
                                   color: line.color,
                                   isVisible: line.isVisible)
                }
                lines.append(newLine)
            }
            
            let newChart = Chart(dateAxis: newDateAxis, lines: lines)
            graph.chartView.displayChart(chart: newChart)
        }
    }
}
