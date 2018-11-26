/*
 The assembler model is the model of the Model View Controller
 */

import ARKit

class AssemblerModel: Model
{
    var foundObjects: [ObjectPart]
    var instructionHasFailed: Bool
    var numberOfPlanesDetected: Int
    {
        didSet
        {
            if numberOfPlanesDetected == 0 { doneSetup = false }
            DispatchQueue.main.async {
                self.callback()
            }
        }
    }
    
    var summedPlaneAreas: Float
    {
        didSet
        {
            if detectedPlaneProgress >= 1.0 { self.doneSetup = true }
            DispatchQueue.main.async {
                self.callback()
            }
        }
    }
    
    var detectedPlaneProgress: Float
    {
        return summedPlaneAreas / minimumPlaneArea
    }
    
    var minimumPlaneArea: Float
    var doneSetup: Bool
    
    var callback =
    {
        print("Callback function has not been implemented")
    }
    
    init()
    {
        instructionHasFailed = false
        doneSetup = false
        numberOfPlanesDetected = 0
        summedPlaneAreas = 0.0
        minimumPlaneArea = 2.5
        foundObjects = []
    }
    
    func isValid() -> Bool
    {
        return numberOfPlanesDetected > 0 && doneSetup
    }
}
