import SceneKit

protocol InstructionExecutionerDelegate
{
    func getPixelBuffer() -> CVPixelBuffer?
    func instructionCompleted()
    func getWorldPosition(_ rect: ObjectRectangle) -> SCNVector3?
    func newInstructionSet(_ instruction: Instruction?)
    func instructionFailed(_ instruction: Instruction?, error: Error?)
}
