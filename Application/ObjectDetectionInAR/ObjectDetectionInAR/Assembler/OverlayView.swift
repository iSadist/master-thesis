/*
 OverlayView is used to be an overlay over the ARSceneView as a
 means to display instructions to the user. These instructions
 are in the forms of rectangles.
 */

import UIKit

class OverlayView: UIView
{
    // The rectangles are passed in the Vision coordinate system
    // which starts in the lower left corner and goes from 0-1.
    var rectangles = [ObjectRectangle]()

    override func draw(_ rect: CGRect)
    {
        let context = UIGraphicsGetCurrentContext()!
        context.clear(rect)

        let color = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(3)
        
        for rectangle in rectangles
        {
            context.stroke(rectangle.getRect())
        }
    }

    func clearDisplay()
    {
        rectangles.removeAll()
        setNeedsDisplay()
    }
}
