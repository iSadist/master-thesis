import UIKit

protocol InstructionExecutionerDelegate
{
    func getFrame() -> UIImage?
    func nextInstruction()
    func connectParts(rects: [CGRect])
}
