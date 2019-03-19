
import UIKit

open class LinePlot : Plot {
    
    // Public settings for the LinePlot
    // ################################
    
    /// Specifies how thick the graph of the line is. In points.
    open var lineWidth: CGFloat = 2
    
    /// The color of the graph line. UIColor.
    open var lineColor: UIColor = UIColor.black
    
    /// How each segment in the line should connect. Takes any of the Core Animation LineJoin values.
    open var lineJoin: String = CAShapeLayerLineJoin.round.rawValue
    
    /// The line caps. Takes any of the Core Animation LineCap values.
    open var lineCap: String = CAShapeLayerLineCap.round.rawValue
    
    // Private State
    // #############
    
    private var lineLayer: LineDrawingLayer?
    
    public init(identifier: String) {
        super.init()
        self.identifier = identifier
    }
    
    override func layers(forViewport viewport: CGRect) -> [ScrollableGraphViewDrawingLayer?] {
        createLayers(viewport: viewport)
        return [lineLayer]
    }
    
    private func createLayers(viewport: CGRect) {
        
        // Create the line drawing layer.
        lineLayer = LineDrawingLayer(frame: viewport, lineWidth: lineWidth, lineColor: lineColor, lineJoin: lineJoin, lineCap: lineCap)
        
        // Depending on whether we want to fill with solid or gradient, create the layer accordingly.
        
        lineLayer?.owner = self
    }
}
