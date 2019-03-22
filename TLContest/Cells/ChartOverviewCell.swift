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
        graph.layer.masksToBounds = true
        graph.backgroundColor = Colors.shared.primaryColor
        graph.translatesAutoresizingMaskIntoConstraints = false
        addSubview(graph)
        
        let chartView = ChartOverview()
        chartView.slider.lowerValue = 0.0
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
        graph.displayChart(chart: chart, yRange: sliderRange())
        chartView.displayChart(chart)
    }
    
    func sliderRange() -> ClosedRange<Int> {
        let oldDateAxis = self.chart.dateAxis
        var lowerBoundIndex = Int(Double(oldDateAxis.count) * (chartView.slider.lowerValue)) - 1
        let upperBoundIndex = Int(Double(oldDateAxis.count) * (chartView.slider.upperValue)) - 1
        if lowerBoundIndex < 0 {
            lowerBoundIndex = 0
        }
        return lowerBoundIndex...upperBoundIndex
    }
    
    @objc func sliderDidChangeValue() {
        if fabs(previousLowerRangeValue - chartView.slider.lowerValue) > 0.05 ||
            fabs(previousUpperRangeValue - chartView.slider.upperValue) > 0.05 {
            
            let floatLower = CGFloat(chartView.slider.lowerValue)
            let floatUpper = CGFloat(chartView.slider.upperValue)
            
            let percentOfVisible = floatUpper - floatLower
            let timesToIncreaseFrame = 1.0 / CGFloat(percentOfVisible)
            
            let lineViews = graph.chartView.layer.sublayers?.compactMap({ $0 as? LineView }) ?? []
            //            CATransaction.begin()
            //            CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
            //            CATransaction.setValue(NSNumber.init(value: 0.0), forKey: kCATransactionAnimationDuration)
            let actionsToDisableMovements = [
                "bounds": NSNull(),
                "position": NSNull()
            ]
            for lineView in lineViews {
                var newFrame = lineView.frame
                newFrame.origin.x = -graph.chartView.frame.width * floatLower * timesToIncreaseFrame
                newFrame.size.width = graph.chartView.frame.width * timesToIncreaseFrame
                lineView.frame = newFrame
                lineView.actions = actionsToDisableMovements
            }
            //            CATransaction.commit()
            graph.displayChart(chart: chart, yRange: sliderRange())
            
        }
    }
}
