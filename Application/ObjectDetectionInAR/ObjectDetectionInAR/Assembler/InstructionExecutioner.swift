/*
 The InstructionExecutioner accepts an Instruction or any of its
 subclasses and executes it accordingly. It uses the controller
 to reach the object tracker and object detector to be able to do
 what it needs.
 
 This class was created to seperate the controller of the ARScene
 with the logic for executing instructions.
 */

import Foundation
import UIKit

class InstructionExecutioner: ObjectDetectorDelegate
{
    var delegate: InstructionExecutionerDelegate?
    weak var tracker: ObjectTracker?
    weak var detector: ObjectDetector?
    var instruction: Instruction?
    
    private var trackerQueue = DispatchQueue(label: "tracker", qos: DispatchQoS.userInitiated)
    
    init()
    {}
    
    func executeInstruction() -> Bool
    {
        if let scanInstruction = instruction as? ScanInstruction
        {
            tracker?.requestCancelTracking()
            guard let frame = delegate?.getFrame() else { return false }
            detector?.findObjects(frame: frame, parts: [scanInstruction.firstItem!, scanInstruction.secondItem!])
            
            return true
        }
        
        if let assembleInstruction = instruction as? AssembleInstruction
        {
            // Implement function
            
            return true
        }
        
        return instruction != nil
    }
    
    
    // Mark: - Object detector delegate
    
    // Called when the object detector has found some objects
    func objectsFound(objects rects: [CGRect], error: String?)
    {
        delegate?.connectParts(rects: rects)
        startTracking(on: rects)
        instructionComplete()
    }
    
    /* Insert the bounding boxes of the objects that are
     of interest to track and start tracking immediately.*/
    func startTracking(on boundingBoxes: [CGRect])
    {
        tracker?.setObjectsToTrack(objects: boundingBoxes)
        trackerQueue.async{
            self.tracker?.track()
        }
    }
    
    func instructionComplete()
    {
        delegate?.nextInstruction()
    }
}
