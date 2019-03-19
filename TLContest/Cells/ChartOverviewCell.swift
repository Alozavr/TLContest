//
//  ChartOverviewCell.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

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

////
////  ChartOverviewCell.swift
////  TLContest
////
////  Created by Dmitry Grebenschikov on 12/03/2019.
////  Copyright © 2019 dd-team. All rights reserved.
////
//
//import UIKit
//
//class ChartOverviewCell: UITableViewCell {
//    
//    weak var graph: ScrollableGraphView!
//    weak var chartView: ChartOverview!
//    
//    var previousLowerRangeValue: Double = 0
//    var previousUpperRangeValue: Double = 0
//    
//    var chart: Chart!
//    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        initChart()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initChart()
//    }
//    
//    private func initChart() {
//        selectionStyle = .none
//        contentView.backgroundColor = Colors.shared.primaryColor
//        backgroundColor = Colors.shared.primaryColor
//        
//        let graph = ScrollableGraphView(frame: .zero, dataSource: self)
//        graph.backgroundColor = Colors.shared.primaryColor
//        graph.backgroundFillColor = Colors.shared.primaryColor
//        graph.isScrollEnabled = false
//        graph.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(graph)
//        
//        let chartView = ChartOverview()
//        chartView.slider.lowerValue = 0.8
//        chartView.slider.upperValue = 1.0
//        chartView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(chartView)
//        
//        chartView.slider.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
//        
//        graph.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        graph.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
//        graph.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
//        graph.heightAnchor.constraint(equalToConstant: 200).isActive = true
//        
//        chartView.topAnchor.constraint(equalTo: topAnchor, constant: 200 + 32).isActive = true
//        chartView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
//        chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
//        chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
//        chartView.heightAnchor.constraint(equalToConstant: 64).isActive = true
//        
//        self.graph = graph
//        self.chartView = chartView
//    }
//    
//    func setChart(_ chart: Chart) {
//        self.chart = chart
//        //        graph.displayChart(chart)
//        chartView.displayChart(chart)
//        sliderDidChangeValue()
//        
//        if graph.plots.isEmpty {
//            for line in chart.lines {
//                let plot = LinePlot(identifier: line.id)
//                plot.lineWidth = 1.0
//                plot.lineColor = line.color
//                graph.addPlot(plot: plot)
//            }
//        }
//    }
//    
//    @objc func sliderDidChangeValue() {
//        if fabs(previousLowerRangeValue - chartView.slider.lowerValue) > 0.05 ||
//            fabs(previousUpperRangeValue - chartView.slider.upperValue) > 0.05 {
//            
//            //            let oldDateAxis = self.chart.dateAxis
//            //
//            //            let lowerBoundIndex = Int(Double(oldDateAxis.count) * (chartView.slider.lowerValue))
//            //            let upperBoundIndex = Int(Double(oldDateAxis.count) * (chartView.slider.upperValue))
//            //
//            let coeff = CGFloat(chartView.slider.upperValue - chartView.slider.lowerValue)
//            
//            graph.contentOffset.x = graph.contentSize.width * CGFloat(chartView.slider.lowerValue)
//            
//            guard !graph.plots.isEmpty, !chart.dateAxis.isEmpty else { return }
//            
//            //            graph.rangeMin = chartView.slider.lowerValue * 100.0
//            //            graph.rangeMax = chartView.slider.upperValue * 100.0
//            //
//            let x1: CGFloat = 0.2
//            let y1: CGFloat = 20
//            let xMinusX1 = (coeff - x1)
//            let y2MinusY1 = graph.bounds.width / (CGFloat(chart.dateAxis.count)) - y1
//            let x2MunusX1 = (1.0 - x1)
//            graph.dataPointSpacing = xMinusX1 * y2MinusY1 / x2MunusX1 + y1
//            graph.reload()
//            
//            //            var newDateAxis = oldDateAxis
//            //            if upperBoundIndex > lowerBoundIndex, oldDateAxis.count >= upperBoundIndex {
//            //                newDateAxis = Array(oldDateAxis[lowerBoundIndex..<upperBoundIndex])
//            //            }
//            
//            //            var lines: [Line] = []
//            //            for line in chart.lines {
//            //                var newLine = line
//            //                if upperBoundIndex > lowerBoundIndex, line.values.count >= upperBoundIndex {
//            //                    let newValues = Array(newLine.values[lowerBoundIndex..<upperBoundIndex])
//            //                    newLine = Line(id: line.id,
//            //                                   name: line.name,
//            //                                   values: newValues,
//            //                                   color: line.color,
//            //                                   isVisible: line.isVisible)
//            //                }
//            //                lines.append(newLine)
//            //            }
//            
//            //            let newChart = Chart(dateAxis: newDateAxis, lines: lines)
//            //            graph.chartView.displayChart(chart: newChart)
//        }
//    }
//}
//
//extension ChartOverviewCell: ScrollableGraphViewDataSource {
//    func value(forPlot plot: Plot, atIndex pointIndex: Int) -> Double {
//        guard let line = chart.lines.first(where: { $0.id == plot.identifier }) else {
//            return 0
//        }
//        return Double(line.values[pointIndex])
//    }
//    
//    func numberOfPoints() -> Int {
//        return chart.dateAxis.count
//    }
//}
