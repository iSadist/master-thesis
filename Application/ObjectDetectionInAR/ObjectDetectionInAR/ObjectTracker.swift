import Foundation
import UIKit
import Vision
import ARKit

private let framesPerSecond = 10.0
private var millisecondsPerFrame = 1.0/framesPerSecond * 1000

class ObjectTracker
{
    let trackingView: ARSCNView
    let overlay: OverlayView
    var trackingObservations = [UUID: VNDetectedObjectObservation]()
    var trackingRequests = [VNRequest]()
    var objectsToTrack: [CGRect]
    var trackedObjects = [UUID: CGRect]()
    var cancelTracking: Bool = false
    var delegate: ObjectTrackerDelegate?
    
    let requestHandler = VNSequenceRequestHandler()
    let converter = ImageConverter()
    
    var posX = 1
    var posY = 1
    
    init(view: ARSCNView, objects: [CGRect], overlay: OverlayView)
    {
        trackingView = view
        objectsToTrack = objects
        self.overlay = overlay
    }
    
    func track()
    {
        for object in objectsToTrack
        {
            let observation = VNDetectedObjectObservation(boundingBox: object)
            trackingObservations[observation.uuid] = observation
            trackedObjects[observation.uuid] = object
            
            let request = VNTrackObjectRequest(detectedObjectObservation: observation)
            request.trackingLevel = .fast
            
            trackingRequests.append(request)
        }
        
        while true
        {
            if cancelTracking { break }
            
            var rects = [CGRect]()
            
            guard let frame = delegate?.getFrame() else {
                usleep(useconds_t(millisecondsPerFrame * 1000))
                continue
            }
            
            guard let pixelBuffer = converter.convertImageToPixelBuffer(image: frame) else { continue }

            try? requestHandler.perform(trackingRequests, on: pixelBuffer, orientation: CGImagePropertyOrientation.up)

            for processedRequest in trackingRequests
            {
                guard let result = processedRequest.results?.first as? VNDetectedObjectObservation else { continue }
                trackedObjects[result.uuid] = result.boundingBox
                rects.append(result.boundingBox)
            }

            delegate?.displayRects(rects: rects)

            usleep(useconds_t(millisecondsPerFrame * 1000))
        }
    }
    
    func requestCancelTracking()
    {
        cancelTracking = true
    }
}
