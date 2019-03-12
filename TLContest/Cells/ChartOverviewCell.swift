//
//  ChartOverviewCell.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartOverviewCell: UITableViewCell {
    
    weak var chartView: ChartOverview!
    
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
        let chartView = ChartOverview()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)
        chartView.bindToSuperView()
        self.chartView = chartView
    }
}
