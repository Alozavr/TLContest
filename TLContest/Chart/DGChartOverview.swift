//
//  DGChartOverview.swift
//  TLContest
//
//  Created by Dmitry Grebenschikov on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//

import UIKit

class DGChartOverview: UIView {
    
    weak var sliderView: RangeSlider!
    weak var sliderLeadingConstraint: NSLayoutConstraint!
    weak var sliderTrailingConstraint: NSLayoutConstraint!
    let sliderViewCornerRadius: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    func initialSetup() {
        setupSlider()
        setupSliderBackground()
    }
    
    func displayChart(_ chart: Chart) {
        subviews.filter({ $0 is ChartView }).forEach({ $0.removeFromSuperview() })
        let chartView = ChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chartView)
        chartView.bindToSuperView(with: .init(top: 1, left: 0, bottom: 1, right: 0))
        chartView.displayChart(chart)
        sendSubviewToBack(chartView)
    }
    
    // MARK: - Private
    
    private func setupSliderBackground() {
        let leftBackgroundView = UIView()
        let rightBackgroundView = UIView()
        
        leftBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftBackgroundView)
        leftBackgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        NSLayoutConstraint.activate([
            leftBackgroundView.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: 1),
            leftBackgroundView.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: -1),
            leftBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftBackgroundView.trailingAnchor.constraint(equalTo: sliderView.leadingAnchor, constant: sliderViewCornerRadius)
            ])
        sendSubviewToBack(leftBackgroundView)

        rightBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightBackgroundView)
        rightBackgroundView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        NSLayoutConstraint.activate([
            rightBackgroundView.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: 1),
            rightBackgroundView.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: -1),
            rightBackgroundView.leadingAnchor.constraint(equalTo: sliderView.trailingAnchor, constant: -sliderViewCornerRadius),
            rightBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        sendSubviewToBack(rightBackgroundView)
    }
    
    private func setupSlider() {
        let slider = RangeSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)
        slider.toggleWidth = 15
        slider.bindToSuperView()
        sliderView = slider
        sliderView.layer.cornerRadius = sliderViewCornerRadius
        sliderView.clipsToBounds = true

        setupSliderRecognizers()
        guard let leading = constraints.first(where: { $0.firstItem is RangeSlider && $0.firstAttribute == .leading }) else { return }
        sliderLeadingConstraint = leading
        guard let trailing = constraints.first(where: { $0.firstItem is RangeSlider && $0.firstAttribute == .trailing }) else { return }
        sliderTrailingConstraint = trailing
        
    }
    
    private func setupSliderRecognizers() {
        let leftRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleLeftPan(_:)))
        leftRecognizer.delegate = self
        sliderView.leftToggle.addGestureRecognizer(leftRecognizer)
        let rightRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleRightPan(_:)))
        rightRecognizer.delegate = self
        sliderView.rightToggle.addGestureRecognizer(rightRecognizer)
        let centerRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCenterPan(_:)))
        centerRecognizer.delegate = self
        sliderView.centerToggle.addGestureRecognizer(centerRecognizer)
    }
    
    @objc private func handleCenterPan(_ recognizer: UIPanGestureRecognizer) {
        let newX = sliderView.frame.origin.x + recognizer.translation(in: self).x
        recognizer.setTranslation(.zero, in: self)
        guard newX >= 0, newX <= bounds.width - sliderView.bounds.width else { return }
        sliderLeadingConstraint.constant = newX
        sliderTrailingConstraint.constant = -(bounds.width - newX - sliderView.bounds.width)
    }
    
    @objc private func handleLeftPan(_ recognizer: UIPanGestureRecognizer) {
        let newX = sliderLeadingConstraint.constant + recognizer.translation(in: self).x
        recognizer.setTranslation(.zero, in: self)
        guard newX >= 0, newX < sliderView.frame.origin.x + sliderView.frame.width - 2*sliderView.toggleWidth else { return }
        sliderLeadingConstraint.constant = newX
    }
    
    @objc private func handleRightPan(_ recognizer: UIPanGestureRecognizer) {
        let newX = sliderTrailingConstraint.constant + recognizer.translation(in: self).x
        recognizer.setTranslation(.zero, in: self)
        guard newX <= 0, abs(newX) < bounds.width - sliderView.frame.origin.x - 2*sliderView.toggleWidth else {
            return
        }
        sliderTrailingConstraint.constant = newX
        
    }
}

extension DGChartOverview: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}
