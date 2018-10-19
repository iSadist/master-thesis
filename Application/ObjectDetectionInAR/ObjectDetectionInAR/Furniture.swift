import Foundation
import UIKit

class Furniture
{
    let name: String
    let id: String
    let description: String
    let icon: UIImage
    var instructions: [Instruction]?
    
    convenience init(name: String, id: String, description: String, icon: UIImage, instructions: [Instruction])
    {
        self.init(name: name, id: id, description: description, icon: icon)
        self.instructions = instructions
    }
    
    init(name: String, id: String, description: String, icon: UIImage)
    {
        self.name = name
        self.id = id
        self.description = description
        self.icon = icon
    }
}
