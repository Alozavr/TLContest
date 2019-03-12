//
//  ChartOverview.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 12/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class ChartOverview: UIView {

    var overview: ChartView!
    var slider: RangeSlider!
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let rangeSlider = RangeSlider(frame: .zero)
        let overview = ChartView()
        overview.backgroundColor = .white
        
        addSubview(overview)
        addSubview(rangeSlider)
        
        rangeSlider.addTarget(self, action: #selector(sad), for: .valueChanged)
        
        overview.translatesAutoresizingMaskIntoConstraints = false
        rangeSlider.translatesAutoresizingMaskIntoConstraints = false
        
        overview.bindToSuperView()
        rangeSlider.bindToSuperView()
        
        self.overview = overview
        self.slider = rangeSlider
    }
    
    init(frame: CGRect, chart: Chart) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.overview.displayChart(chart)
    }
    
    func displayChart(_ chart: Chart) {
        overview.displayChart(chart)
    }
    
    @objc func sad() {
        print(slider.upperValue - slider.lowerValue)
    }
    
}
