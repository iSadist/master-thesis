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
    var tracker: ObjectTracker?
    var detector: ObjectDetector?
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
    var repeatTimer: Timer?
    let repeatTimeIntervalInSeconds: Int = 1
    let totalAttemptsBeforeCancel: Int = 20
    private let trackerQueue = DispatchQueue(label: "tracker", qos: DispatchQoS.userInitiated)
    private let workerQueue = DispatchQueue(label: "worker", qos: DispatchQoS.userInitiated)
    
    func executeInstruction()
    {
        attempts += 1
        
        if let scanInstruction = currentInstruction as? ScanInstruction
        {
            detectAndTrackObjects(objects: [scanInstruction.firstItem!, scanInstruction.secondItem!])
        }
        
        if let assembleInstruction = currentInstruction as? AssembleInstruction
        {
            repeatTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(repeatTimeIntervalInSeconds), repeats: true, block: {_ in
                print("Assemble instruction...")
                self.detectAndTrackObjects(objects: [assembleInstruction.firstItem!, assembleInstruction.secondItem!, assembleInstruction.assembledItem!])
            })
            repeatTimer?.fire()
        }
    }
    
    func nextInstruction()
    {
        repeatTimer?.invalidate()
        
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
    
    func detectAndTrackObjects(objects: [String])
    {
        guard let frame = delegate?.getFrame() else { return }
        let imageConvert = ImageConverter()
        guard let pixelBuffer =  imageConvert.convertImageToPixelBuffer(image: frame) else { return }
        workerQueue.async {
            self.detector?.findObjects(pixelBuffer: pixelBuffer, parts: objects)
        }
    }
    
    /* Insert the bounding boxes of the objects that are
     of interest to track and start tracking immediately.*/
    func startTracking(on boundingBoxes: [ObjectRectangle])
    {
        tracker?.requestCancelTracking()
        for boundingBox in boundingBoxes
        {
            boundingBox.addPadding()
        }
        
        tracker?.setObjectsToTrack(objects: boundingBoxes)
        trackerQueue.async {
            self.tracker?.track()
        }
    }
    
    func instructionComplete()
    {
        repeatTimer?.invalidate()
        delegate?.instructionCompleted()
    }
    
    // Mark: - Object detector delegate
    
    // Called when the object detector has found some objects
    func objectsFound(objects rects: [ObjectRectangle], error: String?)
    {
        if currentInstruction is ScanInstruction
        {
            // We expect two objects to be found when scan instruction
            if rects.count != 2
            {
                // Handle error
                guard attempts < totalAttemptsBeforeCancel else
                {
                    attempts = 0
                    self.delegate?.instructionFailed(error: InstructionExecutionError.FailedAttempts)
                    return
                }
                
                print("Could not find objects. Trying again...")
                executeInstruction()
            }
            else
            {
                startTracking(on: rects)
                instructionComplete()
            }
        }
        
        if let assembleInstruction = currentInstruction as? AssembleInstruction
        {
            let isAssembled = rects.contains { (rectangle) -> Bool in
                return rectangle.name == assembleInstruction.assembledItem
            }
            
            if isAssembled
            {
                instructionComplete()
            }
            else if rects.count == 2
            {
                startTracking(on: rects)
            }
        }
    }
}
