import ARKit

class AssemblerModel: Model
{
    var detectedPlaneNodes: [SCNNode]
    var instructionHasFailed: Bool
    
    init()
    {
        instructionHasFailed = false
        detectedPlaneNodes = []
    }
    
    func isValid()
    {
        // Implement
    }
}
