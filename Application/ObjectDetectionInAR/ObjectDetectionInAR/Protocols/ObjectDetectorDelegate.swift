import UIKit

protocol ObjectDetectorDelegate
{
    func objectsFound(objects rects: [CGRect], error: String?)
}
