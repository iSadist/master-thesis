import UIKit

class OverlayView: UIView
{
    // The rectangles are passed in the Vision coordinate system
    // which starts in the lower left corner and goes from 0-1.
    var rectangles = [CGRect]()
    var visionRects = [CGRect]()

    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()!

        let color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(3)
        
        for rectangle in visionRects
        {
            let translatedRect = translateRectToUIKit(fromVision: rectangle, frame: rect)
            rectangles.append(translatedRect)
        }
        
        for rectangle in rectangles
        {
            context.stroke(rectangle)
        }
        
        rectangles.removeAll()
    }
    
    private func translateRectToUIKit(fromVision rect: CGRect, frame: CGRect) -> CGRect
    {
        let pointY = 1 - rect.minY
        let scaleFactor = frame.size
        let realHeight = rect.height * frame.height
        let realWidth = rect.width * frame.width
        let topLeftCorner = (rect.minX * scaleFactor.width + frame.origin.x, pointY * scaleFactor.height - realHeight)
        let scaledRect = CGRect(x: topLeftCorner.0, y: topLeftCorner.1, width: realWidth, height: realHeight)
        return scaledRect
    }
    
    func storeVisionRects(rects: [CGRect])
    {
        visionRects = rects
    }
    
    func storeRects(rects: [CGRect])
    {
        rectangles = rects
    }
}
