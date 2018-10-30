import Foundation
import UIKit

struct Prediction
{
    let labelIndex: Int
    let confidence: Float
    var boundingBox: CGRect
    var label: String
}
