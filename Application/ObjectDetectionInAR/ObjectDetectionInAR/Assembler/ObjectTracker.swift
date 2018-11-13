/*
 ObjectTracker is responsible for following a bounding box
 of one or many objects in video. This process is started by
 giving the bounding boxes at the setup and calling track().
 
 Other classes that has the instance of ObjectTracker can
 request cancel tracking at any time.
 
 The tracking should be done on a seperate queue to avoid
 a locked state.
 */

import Foundation
import UIKit
import Vision
import ARKit

private let framesPerSecond = 15.0 // Best performance is between 10 and 30
private let millisecondsPerFrame = 1.0/framesPerSecond * 1000
private let confidenceThreshold: Float = 0.2

class ObjectTracker
{
    // These properties are determined at init since no GUI operations are allowed on other queues than main
    let viewFrame: CGRect
    
    var objectsToTrack = [ObjectRectangle]()
    var cancelTracking: Bool = false
    var delegate: ObjectTrackerDelegate?
    
    init(viewFrame: CGRect)
    {
        self.viewFrame = viewFrame
    }
    
    func setObjectsToTrack(objects: [ObjectRectangle])
    {
        objectsToTrack = objects
    }
    
    func track()
    {
        cancelTracking = false
        
        var trackingObservations = [UUID: VNDetectedObjectObservation]()
        var trackedObjects = [UUID: CGRect]()
        let requestHandler = VNSequenceRequestHandler()
        for object in objectsToTrack
        {
            let observation = VNDetectedObjectObservation(boundingBox: object.getNormalizedRect(frame: viewFrame))
            trackingObservations[observation.uuid] = observation
            trackedObjects[observation.uuid] = object.getNormalizedRect(frame: viewFrame)
        }
        
        while true
        {
            if cancelTracking { break }
            
            var rects = [ObjectRectangle]()
            var trackingRequests = [VNRequest]()
            
            guard let frame = delegate?.getFrame() else {
                usleep(useconds_t(millisecondsPerFrame * 1000))
                continue
            }

            for trackingObservation in trackingObservations
            {
                // Create the requests
                let request = VNTrackObjectRequest(detectedObjectObservation: trackingObservation.value)
                request.trackingLevel = .fast
                trackingRequests.append(request)
            }

            try? requestHandler.perform(trackingRequests, on: frame, orientation: CGImagePropertyOrientation.up)

            for processedRequest in trackingRequests
            {
                // Handle the results from the requests
                guard let observation = processedRequest.results?.first as? VNDetectedObjectObservation else { continue }
                
                if observation.confidence > confidenceThreshold
                {
                    trackedObjects[observation.uuid] = observation.boundingBox
                    trackingObservations[observation.uuid] = observation
                    let object = ObjectRectangle(visionRect: observation.boundingBox, frame: viewFrame)
                    rects.append(object)
                }
            }

            DispatchQueue.main.async {
                self.delegate?.trackedRects(rects: rects)
            }
            
            // The tracking will stop if no observation has a high confidence value
            if rects.isEmpty
            {
                DispatchQueue.main.async {
                    self.requestCancelTracking()
                    self.delegate?.trackingLost()
                }
            }

            usleep(useconds_t(millisecondsPerFrame * 1000))
        }
        
        DispatchQueue.main.async {
            self.delegate?.trackingDidStop()
        }
    }
    
    func requestCancelTracking()
    {
        cancelTracking = true
    }
}
