import UIKit

protocol InstructionExecutionerDelegate
{
    func getFrame() -> UIImage?
    func instructionCompleted(error: Error?)
    func connectParts(rects: [CGRect])
}
