import UIKit

protocol InstructionExecutionerDelegate
{
    func getFrame() -> UIImage?
    func instructionCompleted(error: Error?)
    func connectParts(rects: [CGRect])
    func connectParts(rects: [CGRect], with message: String)
}
