import Foundation
import UIKit
import Vision
import ARKit

private let framesPerSecond = 30.0 // Best performance is between 10 and 30
private var millisecondsPerFrame = 1.0/framesPerSecond * 1000

class ObjectTracker
{
    let overlay: OverlayView
    var overlayOriginX: CGFloat = 0
    var overlayOriginY: CGFloat = 0
    var overlayWidth: CGFloat = 0
    var overlayHeight: CGFloat = 0
    
    var objectsToTrack: [CGRect]
    var cancelTracking: Bool = false
    var delegate: ObjectTrackerDelegate?
    
    // MARK: Computed properties
    
    var normalizedObjectsToTrack: [CGRect]
    {
        var normalizedRects = [CGRect]()
        
        for rect in objectsToTrack
        {
            var normalizedRect = rect
            
            normalizedRect.origin.x = (normalizedRect.origin.x - overlayOriginX) / overlayWidth
            normalizedRect.origin.y = (normalizedRect.origin.y - overlayOriginY) / overlayHeight
            normalizedRect.size.width /= overlayWidth
            normalizedRect.size.height /= overlayHeight
            // Adjust to Vision.framework input requrement - origin at LLC
            normalizedRect.origin.y = 1.0 - normalizedRect.origin.y - normalizedRect.size.height
            
            normalizedRects.append(normalizedRect)
        }
        
        return normalizedRects
    }
    
    init(objects: [CGRect], overlay: OverlayView)
    {
        objectsToTrack = objects
        overlayOriginX = overlay.frame.origin.x
        overlayOriginY = overlay.frame.origin.y
        overlayWidth = overlay.frame.size.width
        overlayHeight = overlay.frame.size.height
        self.overlay = overlay
    }
    
    func track()
    {
        var trackingObservations = [UUID: VNDetectedObjectObservation]()
        var trackedObjects = [UUID: CGRect]()
        let requestHandler = VNSequenceRequestHandler()
        
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
                
                if observation.confidence > 0.1
                {
                    trackedObjects[observation.uuid] = observation.boundingBox
                    trackingObservations[observation.uuid] = observation
                    rects.append(observation.boundingBox)
                }
            }

            delegate?.displayRects(rects: rects)
            
            if rects.isEmpty
            {
                requestCancelTracking()
            }

            usleep(useconds_t(millisecondsPerFrame * 1000))
        }
        
        delegate?.trackingDidStop()
    }
    
    func requestCancelTracking()
    {
        cancelTracking = true
    }
}
