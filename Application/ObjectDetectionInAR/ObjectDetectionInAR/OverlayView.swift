import UIKit

class OverlayView: UIView
{
    // The rectangles are passed in the Vision coordinate system
    // which starts in the lower left corner and goes from 0-1.
    var rectangles = [CGRect]()

    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()!

        let color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(2)
        
        for rectangle in rectangles
        {
            let translatedRect = translateRectToUIKit(fromVision: rectangle, frame: rect)
            context.stroke(translatedRect)
        }
    }
    
    private func translateRectToUIKit(fromVision rect: CGRect, frame: CGRect) -> CGRect
    {
        let realHeight = rect.height * frame.height
        let realWidth = rect.width * frame.width
        let topLeftCorner = (rect.maxX * frame.width, frame.height - rect.minY * frame.height)
        let scaledRect = CGRect(x: topLeftCorner.0, y: topLeftCorner.1, width: realWidth, height: realHeight)
        return scaledRect
    }
}
