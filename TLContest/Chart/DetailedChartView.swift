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
    
    var datesLayer: DatesLayer!
    private var tempLineLayers: [CALayer] = []
    
    var currentRange = ClosedRange(uncheckedBounds: (0, 0))
    
    private var cachedChart: Chart = Chart(dateAxis: [], lines: [])
    private var cachedYRange: ClosedRange<Int> = ClosedRange(uncheckedBounds: (0, 0))
    private var cachedMax: CGFloat = 0.0
    private var cachedIsAnimateFromTopToBottom: Bool = false
    private var cachedIsBoundsUpdated: Bool = false
    private var dateFormatters = DateFormatters.shared
    
    let graphViewInsets = UIEdgeInsets(top: 8, left: 16, bottom: 20, right: -16)
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UIView.bounds),
            let changeDict = change,
            let rect = changeDict[.newKey] as? CGRect,
            !rect.isEmpty,
            !cachedIsBoundsUpdated {
            cachedIsBoundsUpdated = true
            addLinesAndTextsWithAnimation(chart: cachedChart,
                                          yRange: cachedYRange,
                                          max: cachedMax,
                                          isAnimateFromTopToBottom: cachedIsAnimateFromTopToBottom,
                                          withAnimation: false)
        }
    }
    
    deinit {
        removeObserver(self, forKeyPath: #keyPath(UIView.bounds), context: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addObserver(self, forKeyPath: #keyPath(UIView.bounds), options: [.new, .initial], context: nil)
        
        let chartView = RangedChartView()
        chartView.backgroundColor = Colors.shared.primaryColor
        
        addSubview(chartView)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        chartView.bindToSuperView(with: graphViewInsets)
        
        self.chartView = chartView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard datesLayer.frame.isEmpty else { return }
        var frame = CGRect.zero
        frame.origin = CGPoint(x: chartView.frame.origin.x, y: bounds.height - 20)
        frame.size = CGSize(width: chartView.bounds.width, height: 20)
        datesLayer.frame = frame
        datesLayer.setNeedsDisplay()
    }
    
    func displayChart(chart: Chart, yRange: ClosedRange<Int>) {
        showLinesAndTextIfNeeded(chart: chart, yRange: yRange)
        chartView.displayChart(chart: chart, yRange: yRange)
        if datesLayer == nil {
            datesLayer = DatesLayer(xAxisCoefficients: chartView.xAxisCoefficients, dates: chart.dateAxis)
            layer.addSublayer(datesLayer)
        }
        self.currentRange = yRange
    }
    
    // MARK: Y Lines
    
    func showLinesAndTextIfNeeded(chart: Chart, yRange: ClosedRange<Int>) {
        var isAnimateFromTopToBottom: Bool = false
        
        let lines = chart.lines.filter { $0.isVisible }
        
        let valuesArray = lines.compactMap({ $0.values[yRange].max() })
        guard let tempmax = valuesArray.max() else { return }
        
        let max = CGFloat(tempmax)
        let delta: CGFloat = max / 100.0 * 7.0 // 7%
        if max > chartView.previousMax + delta {
            isAnimateFromTopToBottom = true
        } else if max < chartView.previousMax - delta {
            isAnimateFromTopToBottom = false
        } else {
            return
        }
        
        self.chartView.previousMax = max
        
        func startAnimation() {
            var layersToRemove = self.tempLineLayers
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.removeTempLayers(inArray: layersToRemove)
                layersToRemove.removeAll()
            }
            
            for (index, layer) in layersToRemove.reversed().enumerated() {
                let animation = layer.getAnimationForHiddingWithDisplacement(with: 0.3,
                                                                             isAnimateFromTopToBottom: !isAnimateFromTopToBottom,
                                                                             index: index - 1)
                animation.delegate = LayerRemover(for: layer)
                layer.add(animation, forKey: "groupRemoverAnim")
            }
            
            self.cachedChart = chart
            self.cachedYRange = yRange
            self.cachedMax = max
            self.cachedIsAnimateFromTopToBottom = isAnimateFromTopToBottom
            
            self.addLinesAndTextsWithAnimation(chart: chart,
                                               yRange: yRange,
                                               max: max,
                                               isAnimateFromTopToBottom: isAnimateFromTopToBottom,
                                               withAnimation: true)
            
            CATransaction.commit()
        }
        
        startAnimation()
    }
    
    func addLinesAndTextsWithAnimation(chart: Chart, yRange: ClosedRange<Int>, max: CGFloat, isAnimateFromTopToBottom: Bool, withAnimation: Bool) {
        let linesCount = 5
        let yLabelInterval = max / CGFloat(linesCount)
        
        let spaceBetweenLines = (bounds.height - graphViewInsets.top - graphViewInsets.bottom) / CGFloat(linesCount)
        let labelHeight: CGFloat = 20.0
        let inset: CGFloat = 8.0
        
        for i in 1...linesCount {
            let y = spaceBetweenLines * CGFloat(i)
            
            let title = String(format: "%d", Int(yLabelInterval * CGFloat(linesCount - i)))
            let labelFrame = CGRect(x: inset,
                                    y: y - labelHeight,
                                    width: CGFloat(title.count) * 12.0,
                                    height: labelHeight)
            
            let container = CAShapeLayer()
            container.frame = labelFrame
            let textLayer = chartView.getLabelLayer(title: title,
                                                    frame: container.bounds,
                                                    font: .systemFont(ofSize: 12.0),
                                                    color: UIColor(hexString: "cbd3dd"),
                                                    alignment: .left)
            container.addSublayer(textLayer)
            layer.addSublayer(container)
            
            let lineLayer = CAShapeLayer()
            lineLayer.frame = CGRect(x: inset, y: y, width: bounds.width - inset, height: 1.0)
            let linePath = UIBezierPath()
            linePath.move(to: CGPoint(x: 0,
                                      y: 0))
            linePath.addLine(to: CGPoint(x: bounds.width,
                                         y: 0))
            linePath.lineWidth = 1.0
            lineLayer.strokeColor = UIColor(hexString: "cbd3dd").withAlphaComponent(0.2).cgColor
            lineLayer.path = linePath.cgPath
            lineLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(lineLayer)
            
            tempLineLayers.append(lineLayer)
            tempLineLayers.append(container)
            
            if withAnimation {
                let a1 = lineLayer.getAnimatationOpacityWithPosition(with: 0.4, isAnimateFromTopToBottom: isAnimateFromTopToBottom, index: i)
                let a2 = textLayer.getAnimatationOpacityWithPosition(with: 0.4, isAnimateFromTopToBottom: isAnimateFromTopToBottom, index: i)
                
                let layerWithAnimation1 = LayerWithAnimation(layer: lineLayer, animation: a1, isAnimationCompleted: false)
                let layerWithAnimation2 = LayerWithAnimation(layer: textLayer, animation: a2, isAnimationCompleted: false)
                
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    layerWithAnimation1.isAnimationCompleted = true
                    layerWithAnimation2.isAnimationCompleted = true
                }
                
                layerWithAnimation1.layer.add(layerWithAnimation1.animation, forKey: "a1")
                layerWithAnimation2.layer.add(layerWithAnimation2.animation, forKey: "a2")
                
                layerWithAnimationArray.append(layerWithAnimation1)
                layerWithAnimationArray.append(layerWithAnimation2)
                
                CATransaction.commit()
            }
        }
    }
    
    var layerWithAnimationArray: [LayerWithAnimation] = []
    
    func removeTempLayers(inArray array: [CALayer]) {
        for sublayer in (layer.sublayers ?? []) {
            if array.contains(sublayer) {
                sublayer.removeFromSuperlayer()
            }
        }
    }
}

class LayerWithAnimation {
    let layer: CALayer
    let animation: CAAnimationGroup
    var isAnimationCompleted: Bool
    init(layer: CALayer, animation: CAAnimationGroup, isAnimationCompleted: Bool) {
        self.layer = layer
        self.animation = animation
        self.isAnimationCompleted = isAnimationCompleted
    }
}

class LayerRemover: NSObject, CAAnimationDelegate {
    private weak var layer: CALayer?
    init(for layer: CALayer) {
        self.layer = layer
        super.init()
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.layer?.removeFromSuperlayer()
    }
}
