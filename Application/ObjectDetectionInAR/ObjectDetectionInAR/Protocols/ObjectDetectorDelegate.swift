import UIKit

protocol ObjectDetectorDelegate
{
    func objectsFound(objects rects: [ObjectRectangle], error: String?)
    func couldNotFindObjects()
}
