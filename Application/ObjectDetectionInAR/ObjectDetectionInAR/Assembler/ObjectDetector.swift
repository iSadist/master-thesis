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

        let imageConvert = ImageConverter()
        guard let pixelBuffer =  imageConvert.convertImageToPixelBuffer(image: frame) else { return }
        let predictions = detectAndClassifyObjects(pixelBuffer: (pixelBuffer))
        let correctParts = predictions.filter {parts.contains($0.label)}.removingDuplicates()
        
        // TODO: -- Convert bounding boxes to UIKit
        
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
    
    func detectAndClassifyObjects(pixelBuffer: CVPixelBuffer) -> [Prediction]
    {
        var predictions: [Prediction] = []
        let mlmodel = MyDetector()
        let userDefined: [String: String] = mlmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]! as! [String : String]
        let labels = userDefined["classes"]!.components(separatedBy: ",")
        let nmsThreshold = Float(userDefined["non_maximum_suppression_threshold"]!) ?? 0.5
        guard let model = try? VNCoreMLModel(for: mlmodel.model) else { return [Prediction]()}
        let request = VNCoreMLRequest(model: model, completionHandler: { (finishedReq, err) in
            let results = finishedReq.results as! [VNCoreMLFeatureValueObservation]
            let unorderedPredictions = self.getPredictions(results: results)
            predictions = self.filterOverlappingPredictions(unorderedPredictions: unorderedPredictions, nmsThreshold: nmsThreshold)
            predictions = self.correctYAxis(predictions: predictions, labels: labels)
        })
        request.imageCropAndScaleOption = .scaleFill
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        return predictions
    }
    
    // Mark: - Private helper functions
    
    private func getPredictions(results: [VNCoreMLFeatureValueObservation]) -> [Prediction]
    {
        let coordinates = results[0].featureValue.multiArrayValue!
        let confidence = results[1].featureValue.multiArrayValue!
        let confidenceThreshold = 0.25
        var unorderedPredictions = [Prediction]()
        let numBoundingBoxes = confidence.shape[0].intValue
        let numClasses = confidence.shape[1].intValue
        let confidencePointer = UnsafeMutablePointer<Double>(OpaquePointer(confidence.dataPointer))
        let coordinatesPointer = UnsafeMutablePointer<Double>(OpaquePointer(coordinates.dataPointer))
        for b in 0..<numBoundingBoxes {
            var maxConfidence = 0.0
            var maxIndex = 0
            for c in 0..<numClasses {
                let conf = confidencePointer[b * numClasses + c]
                if conf > maxConfidence {
                    maxConfidence = conf
                    maxIndex = c
                }
            }
            if maxConfidence > confidenceThreshold {
                let x = coordinatesPointer[b * 4]
                let y = coordinatesPointer[b * 4 + 1]
                let w = coordinatesPointer[b * 4 + 2]
                let h = coordinatesPointer[b * 4 + 3]
                
                let rect = CGRect(x: CGFloat(x - w/2), y: CGFloat(y - h/2),
                                  width: CGFloat(w), height: CGFloat(h))
                
                let prediction = Prediction(labelIndex: maxIndex,
                                            confidence: Float(maxConfidence),
                                            boundingBox: rect, label: "")
                unorderedPredictions.append(prediction)
            }
        }
        return unorderedPredictions
    }

    private func filterOverlappingPredictions(unorderedPredictions: [Prediction], nmsThreshold: Float) -> [Prediction]
    {
        var predictions = [Prediction]()
        let orderedPredictions = unorderedPredictions.sorted { $0.confidence > $1.confidence }
        var keep = [Bool](repeating: true, count: orderedPredictions.count)
        for i in 0..<orderedPredictions.count {
            if keep[i] {
                predictions.append(orderedPredictions[i])
                let bbox1 = orderedPredictions[i].boundingBox
                for j in (i+1)..<orderedPredictions.count {
                    if keep[j] {
                        let bbox2 = orderedPredictions[j].boundingBox
                        if bbox1.IoU(other: bbox2) > nmsThreshold {
                            keep[j] = false
                        }
                    }
                }
            }
        }
        return predictions
    }
    
    private func correctYAxis(predictions: [Prediction], labels: [String])-> [Prediction]
    {
        var tempPredictions = [Prediction]()
        for prediction in predictions{
            let tmp = prediction
            tmp.boundingBox.origin.y = 1.0 - prediction.boundingBox.origin.y - prediction.boundingBox.height
            tmp.label = labels[prediction.labelIndex]
            tempPredictions.append(tmp)
        }
        return tempPredictions
    }
}
