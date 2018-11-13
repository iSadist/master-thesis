/*
 The assembler model is the model of the Model View Controller
 */

import ARKit

class AssemblerModel: Model
{
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
    
    var summedPlaneAreas: Float
    {
        didSet
        {
            DispatchQueue.main.async {
                self.callback()
            }
        }
    }
    
    var detectedPlaneProgress: Float
    {
        return summedPlaneAreas / 4.0
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
        objectsOnScreen = []
        summedPlaneAreas = 0.0
    }
    
    func isValid() -> Bool
    {
        return numberOfPlanesDetected > 0 && detectedPlaneProgress >= 1.0
    }
}
