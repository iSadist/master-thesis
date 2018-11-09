import ARKit

class AssemblerModel: Model
{
    var detectedPlaneNodes: [SCNNode]
    var objectsOnScreen: [ObjectRectangle]
    var instructionHasFailed: Bool
    
    init()
    {
        instructionHasFailed = false
        detectedPlaneNodes = []
        objectsOnScreen = []
    }
    
    func isValid()
    {
        // Implement
    }
}
