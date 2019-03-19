
import UIKit

internal class LineDrawingLayer : ScrollableGraphViewDrawingLayer {
    
    private var currentLinePath = UIBezierPath()
    
    init(frame: CGRect, lineWidth: CGFloat, lineColor: UIColor, lineJoin: String, lineCap: String) {
        
        super.init(viewportWidth: frame.size.width, viewportHeight: frame.size.height)
        
        self.lineWidth = lineWidth
        self.strokeColor = lineColor.cgColor
        
        self.lineJoin = CAShapeLayerLineJoin(rawValue: lineJoin)
        self.lineCap = CAShapeLayerLineCap(rawValue: lineCap)

        self.fillColor = UIColor.clear.cgColor // This is handled by the fill drawing layer.
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createLinePath() -> UIBezierPath {
        
        guard let owner = owner else {
            return UIBezierPath()
        }
        
        // Can't really do anything without the delegate.
        guard let delegate = self.owner?.graphViewDrawingDelegate else {
            return currentLinePath
        }
        
        currentLinePath.removeAllPoints()
        
        let activePointsInterval = delegate.intervalForActivePoints()
        
        let min = delegate.rangeForActivePoints().min
        zeroYPosition = delegate.calculatePosition(atIndex: 0, value: min).y
        
        let firstDataPoint = owner.graphPoint(forIndex: activePointsInterval.lowerBound)
        currentLinePath.move(to: firstDataPoint.location)
        
        for i in activePointsInterval.lowerBound ..< activePointsInterval.upperBound - 1 {
            
            let startPoint = owner.graphPoint(forIndex: i).location
            let endPoint = owner.graphPoint(forIndex: i + 1).location
            
            addStraightLineSegment(startPoint: startPoint,
                                   endPoint: endPoint,
                                   inPath: currentLinePath)
        }
        
        return currentLinePath
    }
    
    private func addStraightLineSegment(startPoint: CGPoint, endPoint: CGPoint, inPath path: UIBezierPath) {
        path.addLine(to: endPoint)
    }
    
    override func updatePath() {
        self.path = createLinePath().cgPath
    }
}
