import UIKit

protocol InstructionExecutionerDelegate
{
    func getFrame() -> UIImage?
    func instructionCompleted()
    func newInstructionSet(_ instruction: Instruction?)
    func instructionFailed(error: Error?)
}
