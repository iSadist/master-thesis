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

    var instructions: [Instruction]?
    var currentInstruction: Instruction?
    {
        willSet
        {
            delegate?.newInstructionSet(newValue)
        }
        didSet
        {
            executeInstruction()
        }
    }
    
    var attempts = 0
    var isInstructionComplete: Bool = false
    
    private var trackerQueue = DispatchQueue(label: "tracker", qos: DispatchQoS.userInitiated)
    private var objectQueue = DispatchQueue(label: "detector", qos: DispatchQoS.userInitiated)
    private var assembleQueue = DispatchQueue(label: "assemble", qos: DispatchQoS.userInitiated)
    
    func executeInstruction()
    {
        attempts += 1
        
        if let scanInstruction = currentInstruction as? ScanInstruction
        {
            guard let frame = delegate?.getFrame() else { return }
            let imageConvert = ImageConverter()
            guard let pixelBuffer =  imageConvert.convertImageToPixelBuffer(image: frame) else { return }
            objectQueue.async {
                self.detector?.findObjects(pixelBuffer: pixelBuffer, parts: [scanInstruction.firstItem!, scanInstruction.secondItem!])
            }
        }
        
        if let assembleInstruction = currentInstruction as? AssembleInstruction
        {
            
        }
    }
    
    func nextInstruction()
    {
        if instructions?.isEmpty ?? true
        {
            currentInstruction = nil
            tracker?.requestCancelTracking()
        }
        else
        {
            currentInstruction = instructions?.removeFirst()
        }
    }
    
    // Mark: - Object detector delegate
    
    // Called when the object detector has found some objects
    func objectsFound(objects rects: [ObjectRectangle], error: String?)
    {
        var boundingBoxes = [CGRect]()
        for rect in rects
        {
            boundingBoxes.append(rect.getRect())
        }
        delegate?.connectParts(rects: boundingBoxes, with: "Put the pieces together")
        startTracking(on: rects)
        instructionComplete()
    }
    
    func couldNotFindObjects()
    {
        // Handle error
        guard attempts < 20 else
        {
            attempts = 0
            self.delegate?.instructionFailed(error: InstructionExecutionError.FailedAttempts)
            return
        }
        
        print("Could not find objects. Trying again...")
        executeInstruction()
    }
    
    /* Insert the bounding boxes of the objects that are
     of interest to track and start tracking immediately.*/
    func startTracking(on boundingBoxes: [ObjectRectangle])
    {
        tracker?.setObjectsToTrack(objects: boundingBoxes)
        trackerQueue.async {
            self.tracker?.track()
        }
    }
    
    func instructionComplete()
    {
        delegate?.instructionCompleted()
    }
}
