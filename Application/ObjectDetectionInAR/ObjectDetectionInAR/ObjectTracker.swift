import Foundation
import UIKit
import Vision
import ARKit

private let framesPerSecond = 20.0 // Best performance is between 10 and 30
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
    
    // MARK: Computed properties
    
    var normalizedObjectsToTrack: [CGRect]
    {
        var normalizedRects = [CGRect]()
        
        for rect in objectsToTrack
        {
            var normalizedRect = rect
            
            normalizedRect.origin.x = (normalizedRect.origin.x - overlay.frame.origin.x) / overlay.frame.size.width
            normalizedRect.origin.y = (normalizedRect.origin.y - overlay.frame.origin.y) / overlay.frame.size.height
            normalizedRect.size.width /= overlay.frame.size.width
            normalizedRect.size.height /= overlay.frame.size.height
            // Adjust to Vision.framework input requrement - origin at LLC
            normalizedRect.origin.y = 1.0 - normalizedRect.origin.y - normalizedRect.size.height
            
            normalizedRects.append(normalizedRect)
        }
        
        return normalizedRects
    }
    
    init(view: ARSCNView, objects: [CGRect], overlay: OverlayView)
    {
        trackingView = view
        objectsToTrack = objects
        self.overlay = overlay
    }
    
    func track()
    {
        for object in normalizedObjectsToTrack
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
