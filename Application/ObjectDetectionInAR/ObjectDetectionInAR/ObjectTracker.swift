import Foundation
import UIKit
import Vision
import ARKit

private let framesPerSecond = 5.0
private var millisecondsPerFrame = 1.0/framesPerSecond * 1000

class ObjectTracker
{
    let trackingView: ARSCNView
    let overlay: OverlayView
    var trackingObservations = [UUID: VNDetectedObjectObservation]()
    var objectsToTrack: [CGRect]
    var trackedObjects = [UUID: CGRect]()
    var cancelTracking: Bool = false
    var delegate: ObjectTrackerDelegate?
    
    let requestHandler = VNSequenceRequestHandler()
    let converter = ImageConverter()
    
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
        }
        
        while true
        {
            if cancelTracking { break }
            
            var rects = [CGRect]()
            var trackingRequests = [VNRequest]()
            
            guard let frame = delegate?.getFrame() else {
                usleep(useconds_t(millisecondsPerFrame * 1000))
                continue
            }
            
            for trackingObservation in trackingObservations
            {
                let request = VNTrackObjectRequest(detectedObjectObservation: trackingObservation.value)
                request.trackingLevel = .fast
                trackingRequests.append(request)
            }

            try? requestHandler.perform(trackingRequests, on: frame, orientation: CGImagePropertyOrientation.up)

            for processedRequest in trackingRequests
            {
                guard let observation = processedRequest.results?.first as? VNDetectedObjectObservation else { continue }
                trackedObjects[observation.uuid] = observation.boundingBox
                trackingObservations[observation.uuid] = observation
                rects.append(observation.boundingBox)
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
