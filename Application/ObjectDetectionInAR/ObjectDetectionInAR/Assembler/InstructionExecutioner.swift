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
    
    func getFrame() -> UIImage?
    {
        return nil
    }
    
    func objectsFound(objects rects: [CGRect], error: String?)
    {
        // Called when the ObjectDetector has found some objects
        
        var shouldConnectPieces = false
        var lastRect: CGRect = CGRect()

        for rect in rects
        {
            controller?.addTrackingRect(rect: rect)
            
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
        
        controller?.startTracking()
        controller?.nextInstruction()
    }
}
