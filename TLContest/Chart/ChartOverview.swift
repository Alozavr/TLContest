//
//  ChartOverview.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartOverview: UIView {

    var overview: DGChartOverview!
    var slider: RangeSlider!
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(frame: CGRect, chart: Chart) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let rangeSlider = RangeSlider(frame: .zero)
        let overview = DGChartOverview(frame: rangeSlider.bounds)
        overview.backgroundColor = .white
        
        addSubview(overview)
        addSubview(rangeSlider)
        
        overview.translatesAutoresizingMaskIntoConstraints = false
        rangeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        overview.bindToSuperView()
        rangeSlider.bindToSuperView()
        
        overview.displayChart(chart)
        
        self.overview = overview
        self.slider = rangeSlider
    }
    
}
