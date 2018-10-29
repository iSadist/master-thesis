import UIKit
import Vision

class ObjectDetector
{
    var delegate: ObjectDetectorDelegate?
    
    init()
    {}
    
    /* Find the rects of any objects in the scene
       then classify them and return the rects that
       are interesting.
    */
    func findObjects(frame: UIImage, parts: [String])
    {
        // Perform this on another DispatchQueue

        var list = [CGRect]()
        
        // Full method not implemented, just hardcoded to be able to design interface
        let cgImage = frame.cgImage
        
        let rect1 = CGRect(x: 100, y: 100, width: 100, height: 100)
        let rect2 = CGRect(x: 200, y: 400, width: 100, height: 100)
        
        var object1 = cgImage?.cropping(to: rect1)
        var object2 = cgImage?.cropping(to: rect2)
        
        list.append(rect1)
        list.append(rect2)

        // Fake delay of 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.delegate?.objectsFound(objects: list, error: nil)
        })
    }
    
    // Classify the object in the image
    func predict(pixelBuffer: CVPixelBuffer) -> VNClassificationObservation?
    {
        var classification: VNClassificationObservation? = nil
        
        guard let model = try? VNCoreMLModel(for: FurnitureNet().model) else { return nil }
        let request = VNCoreMLRequest(model: model, completionHandler: { (finishedReq, err) in
            
            if let observations = finishedReq.results as? [VNClassificationObservation]
            {
                let maxValue = observations.max(by: {(current, next) in current.confidence < next.confidence})
                classification = maxValue
            }
        })
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        
        return classification
    }
}
