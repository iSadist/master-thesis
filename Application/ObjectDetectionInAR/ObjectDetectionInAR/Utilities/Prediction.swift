import Foundation
import UIKit

class Prediction : Hashable
{

    
    let labelIndex: Int
    let confidence: Float
    var boundingBox: CGRect
    var label: String
    
    init(labelIndex: Int, confidence: Float, boundingBox: CGRect,label:String) {
        self.labelIndex = labelIndex
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.label = label
    }
    
    static func == (lhs: Prediction, rhs: Prediction) -> Bool {
        return lhs.label == rhs.label
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(label)
    }
}
