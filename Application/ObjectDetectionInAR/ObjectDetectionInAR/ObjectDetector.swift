import UIKit

class ObjectDetector
{
    var delegate: ObjectDetectorDelegate?
    
    init()
    {}
    
    /* Find the rects of any objects in the scene
       then classify them and return the rects that
       are interesting.
    */
    func findObjects(frame: UIImage)
    {
        var list = [CGRect]()
        
        // Full method not implemented, just hardcoded to be able to design interface
        let cgImage = frame.cgImage
        
        let rect1 = CGRect(x: 0, y: 100, width: 100, height: 100)
        let rect2 = CGRect(x: 200, y: 400, width: 100, height: 100)
        let rect3 = CGRect(x: 300, y: 200, width: 100, height: 100)
        
        var object1 = cgImage?.cropping(to: rect1)
        var object2 = cgImage?.cropping(to: rect2)
        var object3 = cgImage?.cropping(to: rect3)
        
        list.append(rect1)
        list.append(rect2)
        list.append(rect3)
        
        delegate?.objectsFound(objects: list, error: nil)
    }
}
