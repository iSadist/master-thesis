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
        }
        else
        {
            currentInstruction = instructions?.removeFirst()
        }
    }
    
    func detectAndTrackObjects(objects: [String])
    {
        guard let frame = delegate?.getPixelBuffer() else { return }
        workerQueue.async {
            self.detector?.findObjects(pixelBuffer: frame, parts: objects)
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
                    self.delegate?.instructionFailed(currentInstruction, error: InstructionExecutionError.FailedAttempts)
                    return
                }
                
                print("Could not find objects. Trying again...")
                executeInstruction()
            }
            else
            {
                // Decide what to do when objects have been found
                delegate?.instructionCompleted(andFound: rects)
            }
        }
        
        if let assembleInstruction = currentInstruction as? AssembleInstruction
        {
            let isAssembled = rects.contains { (rectangle) -> Bool in
                return rectangle.name == assembleInstruction.assembledItem
            }
            
            if isAssembled
            {
                repeatTimer?.invalidate()
                delegate?.instructionCompleted()
            }
            else if rects.count == 2
            {
                // Implement
            }
        }
    }
}
