import Foundation
import UIKit
import Vision
import ARKit

class ObjectTracker
{
    let trackingView: ARSCNView
    var trackingObservations = [UUID: VNDetectedObjectObservation]()
    var trackingRequests = [VNRequest]()
    var objectsToTrack: [CGRect]
    
    let requestHandler = VNSequenceRequestHandler()
    
    init(view: ARSCNView, objects: [CGRect])
    {
        trackingView = view
        objectsToTrack = objects
    }
    
    func track()
    {
        for object in objectsToTrack
        {
            let observation = VNDetectedObjectObservation(boundingBox: object)
            trackingObservations[observation.uuid] = observation
            
            let request = VNTrackObjectRequest(detectedObjectObservation: observation)
            request.trackingLevel = .fast
            
            trackingRequests.append(request)
        }
        
        let converter = ImageConverter()
        guard let pixelBuffer = converter.convertImageToPixelBuffer(image: trackingView.snapshot()) else { return }
        
        try? requestHandler.perform(trackingRequests, on: pixelBuffer, orientation: CGImagePropertyOrientation.up)
    }
    
}

