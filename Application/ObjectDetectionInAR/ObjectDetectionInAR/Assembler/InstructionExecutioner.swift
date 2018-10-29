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
    weak var controller: AssemblerViewController?
    var instruction: Instruction?
    
    init()
    {}
    
    func executeInstruction()
    {
        if let scanInstruction = instruction as? ScanInstruction
        {
            controller?.tracker?.requestCancelTracking()
            controller?.detector?.findObjects(frame: UIImage(), parts: [scanInstruction.firstItem!, scanInstruction.secondItem!])
        }
        
        if let assembleInstruction = instruction as? AssembleInstruction
        {
            // Implement function
        }
    }
    
    
    // Mark: - Object detector delegate
    
    // Called when the object detector has found some objects
    func objectsFound(objects rects: [CGRect], error: String?)
    {
        var shouldConnectPieces = false
        var lastRect: CGRect = CGRect()

        for rect in rects
        {
            if shouldConnectPieces
            {
                // For every second rect, connect with the previous one
                let firstMidpoint = CGPoint(x: lastRect.midX, y: lastRect.midY)
                let secondMidpoint = CGPoint(x: rect.midX, y: rect.midY)
                controller?.connectPieces(fromScreen: firstMidpoint, to: secondMidpoint)
            }

            lastRect = rect
            shouldConnectPieces = !shouldConnectPieces
        }
        
        controller?.startTracking(on: rects)
        controller?.nextInstruction()
    }
}
