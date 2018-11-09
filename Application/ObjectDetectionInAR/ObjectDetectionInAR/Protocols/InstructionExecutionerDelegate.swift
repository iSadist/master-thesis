import UIKit

protocol InstructionExecutionerDelegate
{
    func getFrame() -> UIImage?
    func instructionCompleted()
    func connectParts(rects: [CGRect])
    func connectParts(rects: [CGRect], with message: String)
    func newInstructionSet(_ instruction: Instruction?)
    func instructionFailed(error: Error?)
}
