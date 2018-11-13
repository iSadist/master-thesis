import UIKit

protocol ObjectTrackerDelegate: class
{
    func trackedRects(rects: [ObjectRectangle])
    func getFrame() -> CVPixelBuffer?
    func trackingDidStop()
    func trackingLost()
}
