/*
 The assembler model is the model of the Model View Controller
 */

import ARKit

class AssemblerModel: Model
{
    var detectedPlaneNodes: [SCNNode]
    var objectsOnScreen: [ObjectRectangle]
    var instructionHasFailed: Bool
    var lostTracking: Bool
    {
        didSet
        {
            DispatchQueue.main.async {
                self.callback()
            }
        }
    }
    
    var numberOfPlanesDetected: Int
    {
        didSet
        {
            DispatchQueue.main.async {
                self.callback()
            }
        }
    }
    
    var callback =
    {
        print("Callback function has not been implemented")
    }
    
    init()
    {
        instructionHasFailed = false
        lostTracking = false
        numberOfPlanesDetected = 0
        detectedPlaneNodes = []
        objectsOnScreen = []
    }
    
    func isValid() -> Bool
    {
        return numberOfPlanesDetected > 0
    }
}
