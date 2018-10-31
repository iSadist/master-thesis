import UIKit

protocol ObjectTrackerDelegate: class
{
    func displayRects(rects: [ObjectRectangle])
    func getFrame() -> CVPixelBuffer?
    func trackingDidStop()
}
