//
//  RangeSlider.swift
//  TLContest
//
//  Created by Alexander Shoshiashvili on 11/03/2019.
//  Copyright © 2019 dd-team. All rights reserved.
//


import UIKit

class RangeSliderTrackLayer: CALayer {
    weak var rangeSlider: RangeSlider?
    
    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        
        let path = UIBezierPath(rect: bounds)
        ctx.addPath(path.cgPath)
        
        // color for backround inside thumbs range
        ctx.setFillColor(UIColor.clear.cgColor)
        let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
        let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
        let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
        ctx.fill(rect)
        
        // color for backround before left thumb
        ctx.setFillColor(UIColor(hexString: "CDCFDF").withAlphaComponent(0.5).cgColor)
        let lowerRect = CGRect(x: 0, y: 0.0, width: lowerValuePosition, height: bounds.height)
        ctx.fill(lowerRect)
        
        // color for backround after right thumb
        ctx.setFillColor(UIColor(hexString: "CDCFDF").withAlphaComponent(0.5).cgColor)
        let upperRect = CGRect(x: upperValuePosition, y: 0.0, width: bounds.width - upperValuePosition, height: bounds.height)
        ctx.fill(upperRect)
        
        // bottom line
        let lowerLine = CGMutablePath()
        lowerLine.move(to: CGPoint(x: lowerValuePosition,
                              y: bounds.height))
        lowerLine.addLine(to: CGPoint(x: upperValuePosition,
                                 y: bounds.height))
        ctx.addPath(lowerLine)
        ctx.setLineWidth(2)
        ctx.setStrokeColor(UIColor(hexString: "CDCFDF").withAlphaComponent(0.8).cgColor)
        ctx.strokePath()
        
        // up line
        let upperLine = CGMutablePath()
        upperLine.move(to: CGPoint(x: lowerValuePosition,
                                   y: 0))
        upperLine.addLine(to: CGPoint(x: upperValuePosition,
                                      y: 0))
        ctx.addPath(upperLine)
        ctx.setLineWidth(2)
        ctx.setStrokeColor(UIColor(hexString: "CDCFDF").withAlphaComponent(0.8).cgColor)
        ctx.strokePath()
        
    }
}

class RangeSliderThumbLayer: CALayer {
    
    enum Direction {
        case left, right
    }
    
    var direction: Direction = .left {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var strokeColor = UIColor(hexString: "CDCFDF").withAlphaComponent(0.9) {
        didSet {
            setNeedsDisplay()
        }
    }
    var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    init(direction: Direction) {
        super.init()
        self.direction = direction
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        
        let corners: UIRectCorner
        
        switch direction {
        case .left:
            corners = [.bottomLeft, .topLeft]
        case .right:
            corners = [.topRight, .bottomRight]
        }
        
        let thumbPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 4.0, height: 4.0))
        
        // Fill
        ctx.setFillColor(UIColor(hexString: "CDCFDF").withAlphaComponent(0.8).cgColor)
        ctx.addPath(thumbPath.cgPath)
        ctx.fillPath()
        
        // Outline
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.setLineWidth(lineWidth)
        ctx.addPath(thumbPath.cgPath)
        ctx.strokePath()
        
        if highlighted {
            ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}

public class RangeSlider: UIControl {
    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer(direction: .left)
    let upperThumbLayer = RangeSliderThumbLayer(direction: .right)
    
    public var minimumValue: Double = 0.0
    public var maximumValue: Double = 1.0
    
    public var lowerValue: Double = 0.2 {
        didSet {
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            updateLayerFrames()
        }
    }
    
    public var upperValue: Double = 0.8 {
        didSet {
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            updateLayerFrames()
        }
    }
    
    fileprivate var previousLocation = CGPoint()
    fileprivate let thumbWidth: CGFloat = 16.0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeLayers()
    }
    
    override public func layoutSublayers(of: CALayer) {
        super.layoutSublayers(of:layer)
        updateLayerFrames()
    }
    
    fileprivate func initializeLayers() {
        layer.backgroundColor = UIColor.clear.cgColor
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: bounds.height)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: bounds.height)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(_ value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    
    // MARK: - Touches
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLocation = touch.location(in: self)
        
        let frameInsideThums = CGRect(x: lowerThumbLayer.frame.origin.x + lowerThumbLayer.frame.width,
                                      y: center.y,
                                      width: upperThumbLayer.frame.origin.x - lowerThumbLayer.frame.origin.x + lowerThumbLayer.frame.width,
                                      height: upperThumbLayer.frame.height)
        
        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        } else if frameInsideThums.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
            upperThumbLayer.highlighted = true
        }
        
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }
    
    var gapBetweenThumbs: Double {
        return Double(thumbWidth) * (maximumValue - minimumValue) / Double(bounds.width)
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previousLocation = location
        
        // Update the values
        if lowerThumbLayer.highlighted, upperThumbLayer.highlighted {
            let gap = (upperValue - lowerValue) * (maximumValue - minimumValue)
            if deltaValue > 0 {
                let oldLowerValue = lowerValue
                upperValue = boundValue(gap + oldLowerValue + deltaValue, toLowerValue: oldLowerValue + gap, upperValue: maximumValue)
                lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gap)
            } else {
                lowerValue = boundValue(upperValue - gap + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gap)
                upperValue = boundValue(gap + lowerValue + deltaValue, toLowerValue: lowerValue + gap, upperValue: maximumValue)
            }
        } else if lowerThumbLayer.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
        }
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}
