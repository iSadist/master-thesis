import UIKit

protocol ObjectTrackerDelegate: class
{
    func displayRects(rects: [CGRect])
    func getFrame() -> CVPixelBuffer?
}
