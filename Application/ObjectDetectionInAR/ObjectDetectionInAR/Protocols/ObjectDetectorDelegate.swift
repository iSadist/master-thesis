import UIKit

protocol ObjectDetectorDelegate
{
    func getFrame() -> UIImage?
    func objectsFound(objects rects: [CGRect], error: String?)
}
