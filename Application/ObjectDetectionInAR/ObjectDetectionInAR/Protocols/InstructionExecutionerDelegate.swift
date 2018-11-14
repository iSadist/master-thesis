import UIKit

protocol InstructionExecutionerDelegate
{
    func getPixelBuffer() -> CVPixelBuffer?
    func instructionCompleted()
    func instructionCompleted(andFound objects: [ObjectRectangle])
    func newInstructionSet(_ instruction: Instruction?)
    func instructionFailed(_ instruction: Instruction?, error: Error?)
}
