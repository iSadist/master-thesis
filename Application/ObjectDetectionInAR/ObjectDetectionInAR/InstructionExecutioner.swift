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

        for rect in rects
        {
            controller?.addTrackingRect(rect: rect)
        }
        controller?.startTracking()
        controller?.nextInstruction()
    }
}
