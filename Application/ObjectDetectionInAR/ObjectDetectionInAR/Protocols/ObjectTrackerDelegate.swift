import UIKit

protocol ObjectTrackerDelegate: class
{
    func getBoundingFrame() -> CGRect?
    func trackedRects(rects: [ObjectRectangle])
    func getFrame() -> CVPixelBuffer?
    func trackingDidStop()
    func trackingLost()
}
